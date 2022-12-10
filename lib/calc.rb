require 'csv'

csv_file = File.open("../mulah_data.csv")
csv_rows = CSV.parse(csv_file, headers: false)

PHONE_ROW_INDEX = 1
STORE_ROW_INDEX = 2
COLLECTED_ROW_INDEX = 3
REDEEMED_ROW_INDEX = 4
BALANCE_ROW_INDEX = 4

redeemed_arr = csv_rows.select { |row| row[REDEEMED_ROW_INDEX].to_i > 0 }
# puts redeemed_arr
# loop redeemed array
# then loop phone array to find all the collected points on compnaies
owing_hash ||= {}
redeemed_arr.each do |redeem_row|
  redeemed_phone = redeem_row[PHONE_ROW_INDEX]
  redeemed_company = redeem_row[STORE_ROW_INDEX]
  redeemed_collected = redeem_row[COLLECTED_ROW_INDEX].to_i
  redeemed_point = redeem_row[REDEEMED_ROW_INDEX].to_i

  phone_records = csv_rows.select { |row| row[PHONE_ROW_INDEX] == redeemed_phone }
  # assign each of the company to the object key
  # e.g. { Alpha: [], Beta: [] } etc.
  owing_hash["#{redeemed_company}"] ||= []
  breakpoint = collected_amount = 0
  # list of user's collected point records
  # puts phone_records.first if redeemed_company == "Beta Sdn Bhd"
  phone_records.each_with_index do |row, index|
    # puts row if redeemed_company == "Beta Sdn Bhd" && index == 0
    # puts row if redeemed_company == "Beta Sdn Bhd" && index == 1
    store = row[STORE_ROW_INDEX]
    collected = row[COLLECTED_ROW_INDEX].to_i

    # we skip the loop if the collected point has been fully utilised
    next if collected == 0

    # stop the loop if total redeemed amount (based on FIFO) has been reached
    break if collected_amount >= redeemed_point

    # accumulate the collected points per phone (user)
    collected_amount += collected

    # when accumulated collected amount is greater than redeemed amount
    if collected_amount > redeemed_point
      # grab the remaining amount of collected points
      # and assign it to the owing list
      partially_redeemed = collected_amount - redeemed_point
      balance = collected - partially_redeemed
      owing_hash["#{redeemed_company}"] << {
        "company": store,
        "amount": balance
      } unless redeemed_company == store # skip if the user are redeeming the same company's point

      # update the collected points with the balance in order for the next loop to take the correct point to perform the calculation (FIFO)
      row[COLLECTED_ROW_INDEX] = partially_redeemed
      break
    else
      owing_hash["#{redeemed_company}"] << {
        "company": store,
        "amount": collected
      } unless redeemed_company == store

      # assign a new column (balance) to save the balance of the current collected point
      # in this case, it will always be 0 cause collected_amount still lesser than the redeemed point
      row[COLLECTED_ROW_INDEX] = 0
    end
  end
end
# beautify and compact the array of hashes (owing_hash) above
# e.g owing_hash = { A: [ {company: B, amount: 100 }, { company C, amount: 50 }, {company: C, amount: 100} ]}
# = new_hash = { A: {company: B, amount: 100}, {company: C, amount: 150} }
new_hash = {}
owing_hash.each do |k,v|
  company = k
  arr = v
  new_hash["#{company}"] ||= []
  arr.each do |a|
    if new_hash["#{company}"].empty?
      new_hash["#{company}"] << {
        company: a[:company],
        amount: a[:amount]
      }
    else
      company_hash = new_hash["#{company}"].select { |x| x[:company] == a[:company] }.first
      if company_hash.nil?
        new_hash["#{company}"] << {
          company: a[:company],
          amount: a[:amount]
        }
      else
        company_hash.merge!(amount: company_hash[:amount] + a[:amount])
      end
    end
  end
end

# beautified hash of arrays
new_hash.each do |k,v|
  v.each do |e|
    # skip if the company has been settled
    next if e[:settled] == true
    # to get main company from current company
    # e.g. current main company = Gamma, array (e) = [ {company: A}, {company: F}]
    # current loop = first, so:
    # new_hash["#{e[:company]}"] will be { A: [ { company G} ]}
    c_arr = new_hash["#{e[:company]}"]

    # to get the { company: G } from the new_hash["#{e[:company]}"]
    c_obj = c_arr.select { |x| x[:company] == k }.first

    # if it is empty, means current company doesn't owe main company
    # and, it wil lbe main company to owe current company
    if c_obj.nil?
      bal = e[:amount]
      puts "#{k} owes #{e[:company]}, amount: #{bal}"

      # to avoid recalculation for companies that has been settled
      e[:settled] = true
    else
      # get the balance of main company redeemed amount - current company redeemed amount
      bal = e[:amount] - c_obj[:amount]

      # when the balance is greater or equal to 0
      # then main company owes the current company
      if bal >= 0
        e[:amount] = bal
        puts "#{k} owes #{e[:company]}, amount: #{bal}"
      else
        # otherwise when the balance is < 0
        # then current company owes the main company
        c_obj[:amount] = bal.abs
        puts "#{e[:company]} owes #{k}, amount: #{bal.abs}"
      end

      # to avoid recalculate for companies that has been settled
      e[:settled] = c_obj[:settled] = true
    end
  end
end

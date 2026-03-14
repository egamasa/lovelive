require 'fileutils'
require 'net/http'

dir_name = 'source'

urls = %w[
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1907843035553214653
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1910585858597531892
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1912796424774832410
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1915731515113431536
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1917785801490063872
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1920888747429949555
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1923001670306611227
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1925200659772526741
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1926908664545157314
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1928380361341649338
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1930220486342128121
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1932047526783258921
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1933286941925028173
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1935295929831018632
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1937116173776351560
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1938168105575874573
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1940340922161766754
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1942137762179858747
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1942833597813264428
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1944678000156348588
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1945763654638678179
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1947935464637534431
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1948638597877252263
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1950467147211415668
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1952658586535866778
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1953657166331883574
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1955450986744459333
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1957362330729054515
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1958416275996352688
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1959871866585350491
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1960695547037368385
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1962428714353881527
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1963181173531967704
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1963943445925646533
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1965693476609401233
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1968440829762027918
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1971141122262172163
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1972996346714976646
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1975128898632630528
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1978005604196376856
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1980609260271853826
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1982728725713039711
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1984214013241110848
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1986347067971981662
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1987843428051308902
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1988891836220600606
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1990351453873950890
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1991401876135506046
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1993320771515826587
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1993965014621868342
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1995765629866131489
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1996554578259497034
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1998680335706362320
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=1999122247110607052
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2000476420196471162
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2001416615225597959
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2003025466274283570
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2003747096332222640
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2006380076620034441
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2008540055032226247
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2009237399352807766
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2011003787507585205
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2011696602696785945
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2013433547831365635
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2014254708689371195
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2015708789987508398
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2016410916506550559
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2018222603937415509
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2018974307469201613
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2019357582629171407
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2020757054395134336
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2022243599799464436
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2023644832842076614
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2024416165716775083
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2026219547934494825
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2026592505379070366
  https://gsm-app.com/lovelive/ikizulive-x-archive/api/x/posts?pagination_token=2026994907827827117
]

FileUtils.mkdir_p(dir_name)

urls.each_with_index do |url, i|
  output_file = File.join(dir_name, '%03d.json' % (i + 1))
  uri = URI.parse(url)
  raise "Invalid scheme: #{uri.scheme}" unless uri.scheme == 'https'
  File.write(output_file, Net::HTTP.get(uri))

  puts "#{output_file} Saved"
  sleep 1
end

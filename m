Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: 2.5.42-mm2 on small systems
Date: Mon, 14 Oct 2002 08:25:29 -0400
References: <20021013160451.GA25494@hswn.dk> <20021013223332.GA870@hswn.dk> <3DA9FA51.2E4129E8@digeo.com>
In-Reply-To: <3DA9FA51.2E4129E8@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210140825.29533.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Bill Davidsen <davidsen@tmr.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have an old 486 with 64m and 512M of disk that I use as a serial console.
It does not have enough space to be useful for much else.  So I decided to
test the low end and tried it with 2.5.42-mm2.  It boots and seems to work 
fine.  Then I tried the resp1 (http://pages.prodigy.net/davidsen/) benchmark.  
With 2.4.18 it works:

Memory size 61 MB
  Starting 1 CPU run with 61 MB RAM, minimum 5 data points at 20 sec intervals
 
.              .          .          .          .          .        .        .
                       _____________ delay ms. ____________                  
           Test        low       high    median     average     S.D.    ratio
         noload   2128.527   2138.035   2129.915   2131.269    0.003    1.000
     smallwrite   4178.129  27436.634   4318.342  11111.745    8.927    5.214
     largewrite   4157.574  78592.200   4222.064  16336.681   24.926    7.665
        cpuload   6109.576   8018.156   6230.810   6425.307    0.600    3.015
      spawnload   5508.218   6934.219   5556.992   5706.077    0.462    2.677
       8ctx-mem  10090.974  22222.700  12662.532  13511.634    3.433    6.340
       2ctx-mem   9330.010  21106.194  10745.474  11650.974    3.612    5.467

with 2.5.42-mm2 it does not finish.  The machine is sort of usable while its runing
and control C has no problem ending the program.  I waited 11 hours for the spawnload
test to complete - it was looking very good before this....

Memory size 61 MB
  Starting 1 CPU run with 61 MB RAM, minimum 5 data points at 20 sec intervals
 
.             .          .          .          .          .        .        .
                       _____________ delay ms. ____________                  
           Test        low       high    median     average     S.D.    ratio
         noload   2262.747   2269.895   2264.050   2264.796    0.002    1.000
     smallwrite   3797.901  12132.336   3875.934   5364.276    2.815    2.369
     largewrite   3857.445  35682.893   3875.064   8405.061   10.531    3.711
        cpuload   5385.148   7589.479   5514.157   5771.985    0.729    2.549

The box was not limited by IO (no swapping nor was there much bi/bo in
vmstat).  About 25% User and 75% system in cpu though.

Ed


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

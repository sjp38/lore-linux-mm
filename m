Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA02493
	for <linux-mm@kvack.org>; Mon, 14 Oct 2002 23:42:56 -0700 (PDT)
Message-ID: <3DABB8EF.5E00AF4E@digeo.com>
Date: Mon, 14 Oct 2002 23:42:55 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.42-mm2 on small systems
References: <20021013160451.GA25494@hswn.dk> <20021013223332.GA870@hswn.dk> <3DA9FA51.2E4129E8@digeo.com> <200210140825.29533.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Bill Davidsen <davidsen@tmr.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> ...
> 
> with 2.5.42-mm2 it does not finish.  The machine is sort of usable while its runing
> and control C has no problem ending the program.  I waited 11 hours for the spawnload
> test to complete - it was looking very good before this....
> 
> Memory size 61 MB
>   Starting 1 CPU run with 61 MB RAM, minimum 5 data points at 20 sec intervals
> 
> .             .          .          .          .          .        .        .
>                        _____________ delay ms. ____________
>            Test        low       high    median     average     S.D.    ratio
>          noload   2262.747   2269.895   2264.050   2264.796    0.002    1.000
>      smallwrite   3797.901  12132.336   3875.934   5364.276    2.815    2.369
>      largewrite   3857.445  35682.893   3875.064   8405.061   10.531    3.711
>         cpuload   5385.148   7589.479   5514.157   5771.985    0.729    2.549
> 
> The box was not limited by IO (no swapping nor was there much bi/bo in
> vmstat).  About 25% User and 75% system in cpu though.

hm.  Works for me.  The default setting are waaay too boring, so
I used ./resp -m2 -M5 -w5

           Test        low       high    median     average   median      avg
         noload    143.168    149.676    143.258    145.602    1.000    1.000
     smallwrite    144.319   4350.325    269.161   1428.881    1.879    9.814
     largewrite    230.759   1129.816    492.421    539.192    3.437    3.703
        cpuload    142.833    207.206    143.374    159.036    1.001    1.092
      spawnload    143.066    313.944    143.240    177.391    1.000    1.218
       8ctx-mem    159.396   5823.791    810.837   2020.066    5.660   13.874
       2ctx-mem    757.203   8192.148   1294.120   2538.975    9.033   17.438

Could be a scheduler thing?  Maybe a bug in the test?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

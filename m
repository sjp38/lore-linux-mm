Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 1F2DC6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:50:39 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id b10so3026677vea.30
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 04:50:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130617160200.27bb5d82df09a26adb8efce5@linux-foundation.org>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
	<CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
	<20130617160200.27bb5d82df09a26adb8efce5@linux-foundation.org>
Date: Tue, 18 Jun 2013 19:50:37 +0800
Message-ID: <CAA_GA1eqEUD+f-ZmXiBXS+UC5honi8kKtDTXV9dSTT=oj6S4Ag@mail.gmail.com>
Subject: Re: [PATCHv13 3/4] zswap: add to mm/
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

>
> So the minor fault rate improved and everything else got worse?

I did the test again, in a new clean environment.
I'm sure the config files are the same except enabled zswap.

                                         v3.10-rc4                   v3.10-rc4
                             2G-parallio-zswapbas         2G-parallio-nozswap
Ops memcachetest-0M               819.00 (  0.00%)           1041.00 ( 27.11%)
Ops memcachetest-198M             736.00 (  0.00%)            973.00 ( 32.20%)
Ops memcachetest-430M             700.00 (  0.00%)            892.00 ( 27.43%)
Ops memcachetest-661M             672.00 (  0.00%)            819.00 ( 21.88%)
Ops memcachetest-893M             675.00 (  0.00%)            775.00 ( 14.81%)
Ops memcachetest-1125M            665.00 (  0.00%)            764.00 ( 14.89%)
Ops memcachetest-1356M            641.00 (  0.00%)            749.00 ( 16.85%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-198M              111.00 (  0.00%)             21.00 ( 81.08%)
Ops io-duration-430M              125.00 (  0.00%)             29.00 ( 76.80%)
Ops io-duration-661M              153.00 (  0.00%)             34.00 ( 77.78%)
Ops io-duration-893M              118.00 (  0.00%)             36.00 ( 69.49%)
Ops io-duration-1125M             142.00 (  0.00%)             43.00 ( 69.72%)
Ops io-duration-1356M             156.00 (  0.00%)             50.00 ( 67.95%)
Ops swaptotal-0M               462237.00 (  0.00%)         469193.00 ( -1.50%)
Ops swaptotal-198M             490462.00 (  0.00%)         496201.00 ( -1.17%)
Ops swaptotal-430M             500469.00 (  0.00%)         520400.00 ( -3.98%)
Ops swaptotal-661M             506038.00 (  0.00%)         538872.00 ( -6.49%)
Ops swaptotal-893M             514930.00 (  0.00%)         522590.00 ( -1.49%)
Ops swaptotal-1125M            521010.00 (  0.00%)         526934.00 ( -1.14%)
Ops swaptotal-1356M            513128.00 (  0.00%)         525241.00 ( -2.36%)
Ops swapin-0M                  246425.00 (  0.00%)         251226.00 ( -1.95%)
Ops swapin-198M                266446.00 (  0.00%)         236126.00 ( 11.38%)
Ops swapin-430M                271586.00 (  0.00%)         265193.00 (  2.35%)
Ops swapin-661M                263404.00 (  0.00%)         280281.00 ( -6.41%)
Ops swapin-893M                263958.00 (  0.00%)         263004.00 (  0.36%)
Ops swapin-1125M               276149.00 (  0.00%)         261962.00 (  5.14%)
Ops swapin-1356M               264214.00 (  0.00%)         262571.00 (  0.62%)
Ops minorfaults-0M             629965.00 (  0.00%)         625759.00 (  0.67%)
Ops minorfaults-198M           641320.00 (  0.00%)         769752.00 (-20.03%)
Ops minorfaults-430M           635270.00 (  0.00%)         678590.00 ( -6.82%)
Ops minorfaults-661M           625123.00 (  0.00%)         669308.00 ( -7.07%)
Ops minorfaults-893M           625165.00 (  0.00%)         656343.00 ( -4.99%)
Ops minorfaults-1125M          624358.00 (  0.00%)         657954.00 ( -5.38%)
Ops minorfaults-1356M          619724.00 (  0.00%)         672035.00 ( -8.44%)
Ops majorfaults-0M              57664.00 (  0.00%)          39395.00 ( 31.68%)
Ops majorfaults-198M            59747.00 (  0.00%)          38758.00 ( 35.13%)
Ops majorfaults-430M            63453.00 (  0.00%)          39819.00 ( 37.25%)
Ops majorfaults-661M            61310.00 (  0.00%)          40171.00 ( 34.48%)
Ops majorfaults-893M            62544.00 (  0.00%)          37576.00 ( 39.92%)
Ops majorfaults-1125M           60866.00 (  0.00%)          36891.00 ( 39.39%)
Ops majorfaults-1356M           66598.00 (  0.00%)          37123.00 ( 44.26%)

It shows clearly that swaptotal and minorfaults get improved a little
if enabled zswap.
But with the cost that the performance of everything else dropped a lot.

--
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

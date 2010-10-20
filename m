Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DF5735F0048
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:02:45 -0400 (EDT)
Subject: Re: oom_killer crash linux system
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <20101020112828.1818.A69D9226@jp.fujitsu.com>
References: <20101020013553.GA7428@localhost>
	 <1287540415.2069.1.camel@myhost>
	 <20101020112828.1818.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 10:58:40 +0800
Message-ID: <1287543520.2074.1.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> 
> can you please try 1) invoke oom 2) get page-types -r again. I'm curious
> that oom makes page accounting lost again. I mean, please send us oom 
> log and "page-types -r" result.
> 
> thanks

ok, i do the experiment and catch the log:

Oct 20 10:39:11 myhost kernel: [ 2187.700171] oom_badness: memoy use
=53, totalpages=506807, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700174] oom_badness: pid = 1280,
oom_score_adj=0, points=-30
Oct 20 10:39:11 myhost kernel: [ 2187.700176] select_bad_process,
===========have choose pid=1280 to kill, points=1
Oct 20 10:39:11 myhost kernel: [ 2187.700178] oom_badness: memoy use
=121, totalpages=506807, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700180] oom_badness: pid = 1281,
oom_score_adj=0, points=-30
Oct 20 10:39:11 myhost kernel: [ 2187.700181] oom_badness: memoy use
=229, totalpages=506807, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700183] oom_badness: pid = 1284,
oom_score_adj=0, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700185] oom_badness: memoy use
=239, totalpages=506807, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700186] oom_badness: pid = 1287,
oom_score_adj=0, points=0
Oct 20 10:39:11 myhost kernel: [ 2187.700188] oom_badness: memoy use
=71, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700190] oom_badness: pid = 1288,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700192] oom_badness: memoy use
=33, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700193] oom_badness: pid = 1317,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700195] oom_badness: memoy use
=36, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700196] oom_badness: pid = 1331,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700198] oom_badness: memoy use
=49, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700200] oom_badness: pid = 1333,
oom_score_adj=0, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700202] oom_badness: memoy use
=26, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700203] oom_badness: pid = 1396,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700205] oom_badness: memoy use
=50, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700207] oom_badness: pid = 1419,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700208] oom_badness: memoy use
=116, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700210] oom_badness: pid = 1438,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700212] oom_badness: memoy use
=21, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700213] oom_badness: pid = 1441,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700215] oom_badness: memoy use
=21, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700217] oom_badness: pid = 1442,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700219] oom_badness: memoy use
=21, totalpages=506807, points=0
Oct 20 10:39:13 myhost kernel: [ 2187.700220] oom_badness: pid = 1443,
oom_score_adj=0, points=-30
Oct 20 10:39:13 myhost kernel: [ 2187.700222] oom_badness: memoy use
=21, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700224] oom_badness: pid = 1444,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700226] oom_badness: memoy use
=20, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700227] oom_badness: pid = 1445,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700229] oom_badness: memoy use
=21, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700231] oom_badness: pid = 1446,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700233] oom_badness: memoy use
=174, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700234] oom_badness: pid = 1455,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700236] oom_badness: memoy use
=164, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700238] oom_badness: pid = 1524,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700240] oom_badness: memoy use
=251, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700241] oom_badness: pid = 1542,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700243] oom_badness: memoy use
=59, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700245] oom_badness: pid = 1562,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700246] oom_badness: memoy use
=2815, totalpages=506807, points=5
Oct 20 10:39:14 myhost kernel: [ 2187.700248] oom_badness: pid = 1656,
oom_score_adj=0, points=5
Oct 20 10:39:14 myhost kernel: [ 2187.700250] select_bad_process,
===========have choose pid=1656 to kill, points=5
Oct 20 10:39:14 myhost kernel: [ 2187.700252] oom_badness: memoy use
=56, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700253] oom_badness: pid = 1663,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700255] oom_badness: memoy use
=227, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700257] oom_badness: pid = 1666,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700258] oom_badness: memoy use
=177, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700260] oom_badness: pid = 1671,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700262] oom_badness: memoy use
=226, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700263] oom_badness: pid = 1701,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700265] oom_badness: memoy use
=1358, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700266] oom_badness: pid = 1709,
oom_score_adj=0, points=-28
Oct 20 10:39:14 myhost kernel: [ 2187.700268] oom_badness: memoy use
=1149, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700270] oom_badness: pid = 1716,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700272] oom_badness: memoy use
=28, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700273] oom_badness: pid = 1717,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700275] oom_badness: memoy use
=41, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700277] oom_badness: pid = 1723,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700278] oom_badness: memoy use
=776, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700280] oom_badness: pid = 1724,
oom_score_adj=0, points=-29
Oct 20 10:39:14 myhost kernel: [ 2187.700282] oom_badness: memoy use
=1363, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700283] oom_badness: pid = 1727,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700285] oom_badness: memoy use
=1363, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700287] oom_badness: pid = 1728,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700288] oom_badness: memoy use
=1363, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700290] oom_badness: pid = 1729,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700292] oom_badness: memoy use
=1363, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700293] oom_badness: pid = 1730,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700295] oom_badness: memoy use
=1363, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700297] oom_badness: pid = 1731,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700298] oom_badness: memoy use
=68, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700300] oom_badness: pid = 1752,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700302] oom_badness: memoy use
=192, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700303] oom_badness: pid = 1754,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700305] oom_badness: memoy use
=11195, totalpages=506807, points=22
Oct 20 10:39:14 myhost kernel: [ 2187.700306] oom_badness: pid = 1756,
oom_score_adj=0, points=-8
Oct 20 10:39:14 myhost kernel: [ 2187.700308] oom_badness: memoy use
=176, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700310] oom_badness: pid = 1775,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700312] oom_badness: memoy use
=292, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700313] oom_badness: pid = 1876,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700315] oom_badness: memoy use
=126, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700317] oom_badness: pid = 1882,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700319] oom_badness: memoy use
=110, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700321] oom_badness: pid = 1883,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700323] oom_badness: memoy use
=132, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700324] oom_badness: pid = 1950,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700326] oom_badness: memoy use
=306, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700327] oom_badness: pid = 1969,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700330] oom_badness: memoy use
=42, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700331] oom_badness: pid = 1996,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700333] oom_badness: memoy use
=378, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700334] oom_badness: pid = 1997,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700336] oom_badness: memoy use
=49, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700338] oom_badness: pid = 1999,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700340] oom_badness: memoy use
=485, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700341] oom_badness: pid = 2004,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700343] oom_badness: memoy use
=4515, totalpages=506807, points=8
Oct 20 10:39:14 myhost kernel: [ 2187.700344] oom_badness: pid = 2005,
oom_score_adj=0, points=8
Oct 20 10:39:14 myhost kernel: [ 2187.700346] select_bad_process,
===========have choose pid=2005 to kill, points=8
Oct 20 10:39:14 myhost kernel: [ 2187.700348] oom_badness: memoy use
=837, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700350] oom_badness: pid = 2014,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700351] oom_badness: memoy use
=97, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700353] oom_badness: pid = 2019,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700354] oom_badness: memoy use
=833, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700356] oom_badness: pid = 2022,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700358] oom_badness: memoy use
=130, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700360] oom_badness: pid = 2032,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700361] oom_badness: memoy use
=1322, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700363] oom_badness: pid = 2036,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700365] oom_badness: memoy use
=172, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700366] oom_badness: pid = 2039,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700368] oom_badness: memoy use
=166, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700370] oom_badness: pid = 2041,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700371] oom_badness: memoy use
=51, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700373] oom_badness: pid = 2042,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700375] oom_badness: memoy use
=5378, totalpages=506807, points=10
Oct 20 10:39:14 myhost kernel: [ 2187.700376] oom_badness: pid = 2046,
oom_score_adj=0, points=10
Oct 20 10:39:14 myhost kernel: [ 2187.700378] select_bad_process,
===========have choose pid=2046 to kill, points=10
Oct 20 10:39:14 myhost kernel: [ 2187.700380] oom_badness: memoy use
=140, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700381] oom_badness: pid = 2048,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700383] oom_badness: memoy use
=1188, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700385] oom_badness: pid = 2056,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700386] oom_badness: memoy use
=584, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700388] oom_badness: pid = 2059,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700390] oom_badness: memoy use
=336, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700391] oom_badness: pid = 2062,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700393] oom_badness: memoy use
=924, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700395] oom_badness: pid = 2063,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700396] oom_badness: memoy use
=369, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700398] oom_badness: pid = 2065,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700400] oom_badness: memoy use
=791, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700401] oom_badness: pid = 2066,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700403] oom_badness: memoy use
=70, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700405] oom_badness: pid = 2067,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700406] oom_badness: memoy use
=41485, totalpages=506807, points=81
Oct 20 10:39:14 myhost kernel: [ 2187.700408] oom_badness: pid = 2069,
oom_score_adj=0, points=81
Oct 20 10:39:14 myhost kernel: [ 2187.700409] select_bad_process,
===========have choose pid=2069 to kill, points=81
Oct 20 10:39:14 myhost kernel: [ 2187.700411] oom_badness: memoy use
=198, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700413] oom_badness: pid = 2077,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700415] oom_badness: memoy use
=1599, totalpages=506807, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700416] oom_badness: pid = 2079,
oom_score_adj=0, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700418] oom_badness: memoy use
=416, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700420] oom_badness: pid = 2081,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700422] oom_badness: memoy use
=264, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700423] oom_badness: pid = 2086,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700425] oom_badness: memoy use
=287, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700426] oom_badness: pid = 2087,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700428] oom_badness: memoy use
=291, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700430] oom_badness: pid = 2088,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700432] oom_badness: memoy use
=434, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700433] oom_badness: pid = 2089,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700435] oom_badness: memoy use
=269, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700436] oom_badness: pid = 2099,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700438] oom_badness: memoy use
=376, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700440] oom_badness: pid = 2101,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700441] oom_badness: memoy use
=995, totalpages=506807, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700443] oom_badness: pid = 2110,
oom_score_adj=0, points=1
Oct 20 10:39:14 myhost kernel: [ 2187.700445] oom_badness: memoy use
=276, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700446] oom_badness: pid = 2113,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700448] oom_badness: memoy use
=177, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700450] oom_badness: pid = 2115,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700451] oom_badness: memoy use
=69, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700453] oom_badness: pid = 2118,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700455] oom_badness: memoy use
=119, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700456] oom_badness: pid = 2129,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700458] oom_badness: memoy use
=2216, totalpages=506807, points=4
Oct 20 10:39:14 myhost kernel: [ 2187.700460] oom_badness: pid = 2133,
oom_score_adj=0, points=-26
Oct 20 10:39:14 myhost kernel: [ 2187.700462] oom_badness: memoy use
=202, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700463] oom_badness: pid = 2145,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700465] oom_badness: memoy use
=213, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700466] oom_badness: pid = 2157,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700468] oom_badness: memoy use
=1183, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700470] oom_badness: pid = 2189,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700471] oom_badness: memoy use
=29, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700473] oom_badness: pid = 2191,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700475] oom_badness: memoy use
=451, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700476] oom_badness: pid = 2193,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700478] oom_badness: memoy use
=36, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700479] oom_badness: pid = 2205,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700481] oom_badness: memoy use
=476, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700483] oom_badness: pid = 2206,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700484] oom_badness: memoy use
=43, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700486] oom_badness: pid = 2277,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700488] oom_badness: memoy use
=3431, totalpages=506807, points=6
Oct 20 10:39:14 myhost kernel: [ 2187.700489] oom_badness: pid = 2278,
oom_score_adj=0, points=-24
Oct 20 10:39:14 myhost kernel: [ 2187.700491] oom_badness: memoy use
=43, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700493] oom_badness: pid = 2282,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700495] oom_badness: memoy use
=51, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700496] oom_badness: pid = 2283,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700498] oom_badness: memoy use
=412, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700500] oom_badness: pid = 2286,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700502] oom_badness: memoy use
=1891, totalpages=506807, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700503] oom_badness: pid = 2319,
oom_score_adj=0, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700505] oom_badness: memoy use
=21095, totalpages=506807, points=41
Oct 20 10:39:14 myhost kernel: [ 2187.700506] oom_badness: pid = 2403,
oom_score_adj=0, points=41
Oct 20 10:39:14 myhost kernel: [ 2187.700508] oom_badness: memoy use
=2021, totalpages=506807, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700510] oom_badness: pid = 2478,
oom_score_adj=0, points=3
Oct 20 10:39:14 myhost kernel: [ 2187.700511] oom_badness: memoy use
=1263, totalpages=506807, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700513] oom_badness: pid = 2487,
oom_score_adj=0, points=2
Oct 20 10:39:14 myhost kernel: [ 2187.700515] oom_badness: memoy use
=191, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700516] oom_badness: pid = 2614,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700518] oom_badness: memoy use
=7232, totalpages=506807, points=14
Oct 20 10:39:14 myhost kernel: [ 2187.700519] oom_badness: pid = 2658,
oom_score_adj=0, points=14
Oct 20 10:39:14 myhost kernel: [ 2187.700521] oom_badness: memoy use
=327, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700523] oom_badness: pid = 2784,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700525] oom_badness: memoy use
=479, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700526] oom_badness: pid = 2796,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700528] oom_badness: memoy use
=3098, totalpages=506807, points=6
Oct 20 10:39:14 myhost kernel: [ 2187.700529] oom_badness: pid = 2882,
oom_score_adj=0, points=6
Oct 20 10:39:14 myhost kernel: [ 2187.700532] oom_badness: memoy use
=36, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700533] oom_badness: pid = 3319,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700535] oom_badness: memoy use
=478, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700536] oom_badness: pid = 3320,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700538] oom_badness: memoy use
=15539, totalpages=506807, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700540] oom_badness: pid = 3436,
oom_score_adj=0, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700541] oom_badness: memoy use
=118, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700543] oom_badness: pid = 3440,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700544] oom_badness: memoy use
=29031, totalpages=506807, points=57
Oct 20 10:39:14 myhost kernel: [ 2187.700546] oom_badness: pid = 3446,
oom_score_adj=0, points=57
Oct 20 10:39:14 myhost kernel: [ 2187.700548] oom_badness: memoy use
=15735, totalpages=506807, points=31
Oct 20 10:39:14 myhost kernel: [ 2187.700549] oom_badness: pid = 3498,
oom_score_adj=0, points=31
Oct 20 10:39:14 myhost kernel: [ 2187.700551] oom_badness: memoy use
=66, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700552] oom_badness: pid = 3506,
oom_score_adj=0, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700554] oom_badness: memoy use
=4007, totalpages=506807, points=7
Oct 20 10:39:14 myhost kernel: [ 2187.700556] oom_badness: pid = 3508,
oom_score_adj=0, points=7
Oct 20 10:39:14 myhost kernel: [ 2187.700557] oom_badness: memoy use
=17404, totalpages=506807, points=34
Oct 20 10:39:14 myhost kernel: [ 2187.700559] oom_badness: pid = 3564,
oom_score_adj=0, points=34
Oct 20 10:39:14 myhost kernel: [ 2187.700560] oom_badness: memoy use
=14779, totalpages=506807, points=29
Oct 20 10:39:14 myhost kernel: [ 2187.700562] oom_badness: pid = 3622,
oom_score_adj=0, points=29
Oct 20 10:39:14 myhost kernel: [ 2187.700563] oom_badness: memoy use
=14386, totalpages=506807, points=28
Oct 20 10:39:14 myhost kernel: [ 2187.700565] oom_badness: pid = 3692,
oom_score_adj=0, points=28
Oct 20 10:39:14 myhost kernel: [ 2187.700567] oom_badness: memoy use
=13580, totalpages=506807, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700568] oom_badness: pid = 3708,
oom_score_adj=0, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700570] oom_badness: memoy use
=16011, totalpages=506807, points=31
Oct 20 10:39:14 myhost kernel: [ 2187.700571] oom_badness: pid = 3770,
oom_score_adj=0, points=31
Oct 20 10:39:14 myhost kernel: [ 2187.700573] oom_badness: memoy use
=19788, totalpages=506807, points=39
Oct 20 10:39:14 myhost kernel: [ 2187.700574] oom_badness: pid = 3889,
oom_score_adj=0, points=39
Oct 20 10:39:14 myhost kernel: [ 2187.700576] oom_badness: memoy use
=23319, totalpages=506807, points=46
Oct 20 10:39:14 myhost kernel: [ 2187.700577] oom_badness: pid = 3903,
oom_score_adj=0, points=46
Oct 20 10:39:14 myhost kernel: [ 2187.700579] oom_badness: memoy use
=14994, totalpages=506807, points=29
Oct 20 10:39:14 myhost kernel: [ 2187.700580] oom_badness: pid = 3927,
oom_score_adj=0, points=29
Oct 20 10:39:14 myhost kernel: [ 2187.700582] oom_badness: memoy use
=15434, totalpages=506807, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700583] oom_badness: pid = 3940,
oom_score_adj=0, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700585] oom_badness: memoy use
=17479, totalpages=506807, points=34
Oct 20 10:39:14 myhost kernel: [ 2187.700586] oom_badness: pid = 3954,
oom_score_adj=0, points=34
Oct 20 10:39:14 myhost kernel: [ 2187.700588] oom_badness: memoy use
=16979, totalpages=506807, points=33
Oct 20 10:39:14 myhost kernel: [ 2187.700589] oom_badness: pid = 3972,
oom_score_adj=0, points=33
Oct 20 10:39:14 myhost kernel: [ 2187.700591] oom_badness: memoy use
=13305, totalpages=506807, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700593] oom_badness: pid = 4002,
oom_score_adj=0, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700594] oom_badness: memoy use
=16434, totalpages=506807, points=32
Oct 20 10:39:14 myhost kernel: [ 2187.700596] oom_badness: pid = 4015,
oom_score_adj=0, points=32
Oct 20 10:39:14 myhost kernel: [ 2187.700597] oom_badness: memoy use
=15376, totalpages=506807, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700599] oom_badness: pid = 4028,
oom_score_adj=0, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700601] oom_badness: memoy use
=13587, totalpages=506807, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700602] oom_badness: pid = 4081,
oom_score_adj=0, points=26
Oct 20 10:39:14 myhost kernel: [ 2187.700604] oom_badness: memoy use
=36, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700605] oom_badness: pid = 4085,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700607] oom_badness: memoy use
=36, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700609] oom_badness: pid = 4086,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700611] oom_badness: memoy use
=35, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700612] oom_badness: pid = 4089,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700614] oom_badness: memoy use
=43, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700615] oom_badness: pid = 4092,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700617] oom_badness: memoy use
=42, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700619] oom_badness: pid = 4093,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700620] oom_badness: memoy use
=55, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700622] oom_badness: pid = 4096,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700624] oom_badness: memoy use
=54, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700625] oom_badness: pid = 4097,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700627] oom_badness: memoy use
=58, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700629] oom_badness: pid = 4128,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700630] oom_badness: memoy use
=58, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700632] oom_badness: pid = 4129,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700634] oom_badness: memoy use
=86, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700636] oom_badness: pid = 4130,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700637] oom_badness: memoy use
=87, totalpages=506807, points=0
Oct 20 10:39:14 myhost kernel: [ 2187.700639] oom_badness: pid = 4131,
oom_score_adj=0, points=-30
Oct 20 10:39:14 myhost kernel: [ 2187.700641] oom_badness: memoy use
=15280, totalpages=506807, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700642] oom_badness: pid = 4141,
oom_score_adj=0, points=30
Oct 20 10:39:14 myhost kernel: [ 2187.700644] acroread invoked
oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
Oct 20 10:39:14 myhost kernel: [ 2187.700647] acroread cpuset=/
mems_allowed=0
Oct 20 10:39:14 myhost kernel: [ 2187.700649] Pid: 3446, comm: acroread
Not tainted 2.6.36testing #7
Oct 20 10:39:14 myhost kernel: [ 2187.700650] Call Trace:
Oct 20 10:39:14 myhost kernel: [ 2187.700656]  [<c10c0a20>]
dump_header.clone.5+0x80/0x1e0
Oct 20 10:39:14 myhost kernel: [ 2187.700660]  [<c12eb5b6>] ? printk
+0x18/0x1a
Oct 20 10:39:14 myhost kernel: [ 2187.700662]  [<c10c0d85>] ?
oom_badness+0x185/0x1a0
Oct 20 10:39:14 myhost kernel: [ 2187.700664]  [<c10c0dfc>]
oom_kill_process+0x5c/0x210
Oct 20 10:39:14 myhost kernel: [ 2187.700666]  [<c10c1031>] ?
select_bad_process.clone.7+0x81/0x100
Oct 20 10:39:14 myhost kernel: [ 2187.700668]  [<c10c134f>]
out_of_memory+0xbf/0x1d0
Oct 20 10:39:14 myhost kernel: [ 2187.700670]  [<c10c1218>] ?
try_set_zonelist_oom+0xc8/0xe0
Oct 20 10:39:14 myhost kernel: [ 2187.700673]  [<c10c4bd8>]
__alloc_pages_nodemask+0x5e8/0x600
Oct 20 10:39:14 myhost kernel: [ 2187.700676]  [<c10c6585>]
__do_page_cache_readahead+0x105/0x230
Oct 20 10:39:14 myhost kernel: [ 2187.700678]  [<c10c6911>] ra_submit
+0x21/0x30
Oct 20 10:39:14 myhost kernel: [ 2187.700680]  [<c10beb8b>]
filemap_fault+0x36b/0x3e0
Oct 20 10:39:14 myhost kernel: [ 2187.700683]  [<c10d5cab>] __do_fault
+0x3b/0x4f0
Oct 20 10:39:14 myhost kernel: [ 2187.700686]  [<c10d8d0d>]
handle_mm_fault+0xfd/0x930
Oct 20 10:39:14 myhost kernel: [ 2187.700689]  [<c1029250>] ?
do_page_fault+0x0/0x3e0
Oct 20 10:39:14 myhost kernel: [ 2187.700691]  [<c10293a0>]
do_page_fault+0x150/0x3e0
Oct 20 10:39:14 myhost kernel: [ 2187.700694]  [<c106a69f>] ?
ktime_get_ts+0xff/0x130
Oct 20 10:39:14 myhost kernel: [ 2187.700697]  [<c1109ce4>] ? sys_poll
+0x54/0xd0
Oct 20 10:39:14 myhost kernel: [ 2187.700699]  [<c1029250>] ?
do_page_fault+0x0/0x3e0
Oct 20 10:39:14 myhost kernel: [ 2187.700702]  [<c12ef1fb>] error_code
+0x67/0x6c
Oct 20 10:39:14 myhost kernel: [ 2187.700703] Mem-Info:
Oct 20 10:39:14 myhost kernel: [ 2187.700704] DMA per-cpu:
Oct 20 10:39:14 myhost kernel: [ 2187.700706] CPU    0: hi:    0, btch:
1 usd:   0
Oct 20 10:39:14 myhost kernel: [ 2187.700707] CPU    1: hi:    0, btch:
1 usd:   0
Oct 20 10:39:14 myhost kernel: [ 2187.700708] Normal per-cpu:
Oct 20 10:39:14 myhost kernel: [ 2187.700709] CPU    0: hi:  186, btch:
31 usd:   0
Oct 20 10:39:14 myhost kernel: [ 2187.700711] CPU    1: hi:  186, btch:
31 usd:  40
Oct 20 10:39:14 myhost kernel: [ 2187.700712] HighMem per-cpu:
Oct 20 10:39:14 myhost kernel: [ 2187.700713] CPU    0: hi:  186, btch:
31 usd:   0
Oct 20 10:39:14 myhost kernel: [ 2187.700714] CPU    1: hi:  186, btch:
31 usd:  52
Oct 20 10:39:14 myhost kernel: [ 2187.700718] active_anon:398375
inactive_anon:82967 isolated_anon:0
Oct 20 10:39:14 myhost kernel: [ 2187.700718]  active_file:81
inactive_file:429 isolated_file:32
Oct 20 10:39:14 myhost kernel: [ 2187.700719]  unevictable:13 dirty:2
writeback:14 unstable:0
Oct 20 10:39:14 myhost kernel: [ 2187.700720]  free:11942
slab_reclaimable:2391 slab_unreclaimable:3303
Oct 20 10:39:14 myhost kernel: [ 2187.700721]  mapped:5617 shmem:33909
pagetables:2280 bounce:0
Oct 20 10:39:14 myhost kernel: [ 2187.700725] DMA free:7984kB min:64kB
low:80kB high:96kB active_anon:3852kB inactive_anon:3968kB
active_file:0kB inactive_file:52kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB
kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:36 all_unreclaimable? no
Oct 20 10:39:14 myhost kernel: [ 2187.700728] lowmem_reserve[]: 0 865
1980 1980
Oct 20 10:39:14 myhost kernel: [ 2187.700734] Normal free:39404kB
min:3728kB low:4660kB high:5592kB active_anon:732980kB
inactive_anon:42036kB active_file:116kB inactive_file:780kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:885944kB
mlocked:0kB dirty:8kB writeback:48kB mapped:6728kB shmem:44600kB
slab_reclaimable:9564kB slab_unreclaimable:13196kB kernel_stack:3200kB
pagetables:9120kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:1207 all_unreclaimable? no
Oct 20 10:39:14 myhost kernel: [ 2187.700737] lowmem_reserve[]: 0 0 8921
8921
Oct 20 10:39:14 myhost kernel: [ 2187.700743] HighMem free:380kB
min:512kB low:1712kB high:2912kB active_anon:856668kB
inactive_anon:285864kB active_file:208kB inactive_file:896kB
unevictable:52kB isolated(anon):0kB isolated(file):0kB present:1141984kB
mlocked:52kB dirty:0kB writeback:8kB mapped:15740kB shmem:91036kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:1398 all_unreclaimable? no
Oct 20 10:39:14 myhost kernel: [ 2187.700746] lowmem_reserve[]: 0 0 0 0
Oct 20 10:39:14 myhost kernel: [ 2187.700749] DMA: 1*4kB 1*8kB 1*16kB
3*32kB 1*64kB 3*128kB 3*256kB 3*512kB 1*1024kB 0*2048kB 1*4096kB =
7996kB
Oct 20 10:39:14 myhost kernel: [ 2187.700755] Normal: 53*4kB 79*8kB
144*16kB 139*32kB 121*64kB 44*128kB 40*256kB 6*512kB 1*1024kB 0*2048kB
1*4096kB = 39404kB
Oct 20 10:39:14 myhost kernel: [ 2187.700761] HighMem: 29*4kB 17*8kB
6*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
= 380kB
Oct 20 10:39:14 myhost kernel: [ 2187.700767] 34452 total pagecache
pages
Oct 20 10:39:14 myhost kernel: [ 2187.700768] 0 pages in swap cache
Oct 20 10:39:14 myhost kernel: [ 2187.700769] Swap cache stats: add 0,
delete 0, find 0/0
Oct 20 10:39:14 myhost kernel: [ 2187.700771] Free swap  = 0kB
Oct 20 10:39:14 myhost kernel: [ 2187.700771] Total swap = 0kB
Oct 20 10:39:14 myhost kernel: [ 2187.704392] 515070 pages RAM
Oct 20 10:39:14 myhost kernel: [ 2187.704393] 287745 pages HighMem
Oct 20 10:39:14 myhost kernel: [ 2187.704394] 8264 pages reserved
Oct 20 10:39:14 myhost kernel: [ 2187.704395] 29765 pages shared
Oct 20 10:39:14 myhost kernel: [ 2187.704396] 478272 pages non-shared
Oct 20 10:39:14 myhost kernel: [ 2187.704397] [ pid ]   uid  tgid
total_vm      rss cpu oom_adj oom_score_adj name
Oct 20 10:39:14 myhost kernel: [ 2187.704404] [  566]     0   566
578      167   0     -17         -1000 udevd
Oct 20 10:39:14 myhost kernel: [ 2187.704407] [ 1280]     0  1280
1280       53   1       0             0 syslog-ng
Oct 20 10:39:14 myhost kernel: [ 2187.704410] [ 1281]     0  1281
1358      121   1       0             0 syslog-ng
Oct 20 10:39:14 myhost kernel: [ 2187.704412] [ 1284]    81  1284
780      229   0       0             0 dbus-daemon
Oct 20 10:39:14 myhost kernel: [ 2187.704415] [ 1287]    82  1287
3757      239   0       0             0 hald
Oct 20 10:39:14 myhost kernel: [ 2187.704418] [ 1288]     0  1288
898       71   0       0             0 hald-runner
Oct 20 10:39:14 myhost kernel: [ 2187.704420] [ 1317]     0  1317
914       33   1       0             0 hald-addon-inpu
Oct 20 10:39:14 myhost kernel: [ 2187.704423] [ 1331]     0  1331
914       36   1       0             0 hald-addon-stor
Oct 20 10:39:14 myhost kernel: [ 2187.704425] [ 1333]    82  1333
823       49   0       0             0 hald-addon-acpi
Oct 20 10:39:14 myhost kernel: [ 2187.704428] [ 1370]     0  1370
577      168   1     -17         -1000 udevd
Oct 20 10:39:14 myhost kernel: [ 2187.704430] [ 1396]     0  1396
451       26   1       0             0 crond
Oct 20 10:39:14 myhost kernel: [ 2187.704433] [ 1419]     0  1419
718       50   1       0             0 mysqld_safe
Oct 20 10:39:14 myhost kernel: [ 2187.704436] [ 1438]     0  1438
3575      116   0       0             0 gdm-binary
Oct 20 10:39:14 myhost kernel: [ 2187.704438] [ 1441]     0  1441
439       21   1       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704441] [ 1442]     0  1442
439       21   0       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704443] [ 1443]     0  1443
439       21   1       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704446] [ 1444]     0  1444
439       21   0       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704448] [ 1445]     0  1445
439       20   0       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704451] [ 1446]     0  1446
439       21   1       0             0 agetty
Oct 20 10:39:14 myhost kernel: [ 2187.704453] [ 1455]     0  1455
2214      174   0       0             0 cupsd
Oct 20 10:39:14 myhost kernel: [ 2187.704456] [ 1517]     0  1517
1647       98   1     -17         -1000 sshd
Oct 20 10:39:14 myhost kernel: [ 2187.704459] [ 1524]     0  1524
6451      164   1       0             0 NetworkManager
Oct 20 10:39:14 myhost kernel: [ 2187.704461] [ 1542]     0  1542
5710      251   0       0             0 polkitd
Oct 20 10:39:14 myhost kernel: [ 2187.704464] [ 1562]     0  1562
2014       59   1       0             0 vmware-usbarbit
Oct 20 10:39:14 myhost kernel: [ 2187.704466] [ 1656]    89  1656
29902     2815   0       0             0 mysqld
Oct 20 10:39:14 myhost kernel: [ 2187.704469] [ 1663]     0  1663
1247       56   0       0             0 wpa_supplicant
Oct 20 10:39:14 myhost kernel: [ 2187.704471] [ 1666]     0  1666
4910      227   0       0             0 smbd
Oct 20 10:39:14 myhost kernel: [ 2187.704474] [ 1671]     0  1671
2807      177   0       0             0 nmbd
Oct 20 10:39:14 myhost kernel: [ 2187.704476] [ 1701]     0  1701
4910      226   1       0             0 smbd
Oct 20 10:39:14 myhost kernel: [ 2187.704479] [ 1709]     0  1709
5162     1358   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704482] [ 1716]    33  1716
4841     1149   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704484] [ 1717]     0  1717
487       28   0       0             0 dhcpcd
Oct 20 10:39:14 myhost kernel: [ 2187.704487] [ 1723]     0  1723
946       41   0       0             0 ApplicationPool
Oct 20 10:39:14 myhost kernel: [ 2187.704489] [ 1724]     0  1724
3555      776   1       0             0 ruby
Oct 20 10:39:14 myhost kernel: [ 2187.704492] [ 1727]    33  1727
5162     1363   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704494] [ 1728]    33  1728
5162     1363   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704496] [ 1729]    33  1729
5162     1363   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704499] [ 1730]    33  1730
5162     1363   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704501] [ 1731]    33  1731
5162     1363   0       0             0 httpd
Oct 20 10:39:14 myhost kernel: [ 2187.704504] [ 1752]     0  1752
854       68   0       0             0 cntlm
Oct 20 10:39:14 myhost kernel: [ 2187.704506] [ 1754]     0  1754
4391      192   0       0             0 gdm-simple-slav
Oct 20 10:39:14 myhost kernel: [ 2187.704509] [ 1756]     0  1756
38002    11195   0       0             0 Xorg
Oct 20 10:39:14 myhost kernel: [ 2187.704512] [ 1775]     0  1775
6671      176   0       0             0 console-kit-dae
Oct 20 10:39:14 myhost kernel: [ 2187.704514] [ 1876]   120  1876
6572      292   0       0             0 polkit-gnome-au
Oct 20 10:39:14 myhost kernel: [ 2187.704517] [ 1882]     0  1882
3666      126   0       0             0 upowerd
Oct 20 10:39:14 myhost kernel: [ 2187.704520] [ 1883]     0  1883
3900      110   1       0             0 gdm-session-wor
Oct 20 10:39:14 myhost kernel: [ 2187.704522] [ 1950]  1000  1950
7737      132   1       0             0 gnome-keyring-d
Oct 20 10:39:14 myhost kernel: [ 2187.704525] [ 1969]  1000  1969
9233      306   1       0             0 gnome-session
Oct 20 10:39:14 myhost kernel: [ 2187.704528] [ 1996]  1000  1996
794       42   0       0             0 dbus-launch
Oct 20 10:39:14 myhost kernel: [ 2187.704530] [ 1997]  1000  1997
1249      378   0       0             0 dbus-daemon
Oct 20 10:39:14 myhost kernel: [ 2187.704533] [ 1999]  1000  1999
886       49   1       0             0 ssh-agent
Oct 20 10:39:14 myhost kernel: [ 2187.704535] [ 2004]  1000  2004
2650      485   1       0             0 gconfd-2
Oct 20 10:39:14 myhost kernel: [ 2187.704538] [ 2005]  1000  2005
11022     4515   0       0             0 fcitx
Oct 20 10:39:14 myhost kernel: [ 2187.704541] [ 2014]  1000  2014
8792      837   0       0             0 gnome-settings-
Oct 20 10:39:14 myhost kernel: [ 2187.704543] [ 2019]  1000  2019
2201       97   1       0             0 gvfsd
Oct 20 10:39:14 myhost kernel: [ 2187.704546] [ 2022]  1000  2022
40893      833   1       0             0 metacity
Oct 20 10:39:14 myhost kernel: [ 2187.704549] [ 2028]     0  2028
577      161   0     -17         -1000 udevd
Oct 20 10:39:14 myhost kernel: [ 2187.704551] [ 2032]  1000  2032
7599      130   0       0             0 gvfs-fuse-daemo
Oct 20 10:39:14 myhost kernel: [ 2187.704554] [ 2036]  1000  2036
46396     1322   0       0             0 gnome-panel
Oct 20 10:39:14 myhost kernel: [ 2187.704556] [ 2039]  1000  2039
8657      172   0       0             0 gvfs-gdu-volume
Oct 20 10:39:14 myhost kernel: [ 2187.704559] [ 2041]     0  2041
5721      166   0       0             0 udisks-daemon
Oct 20 10:39:14 myhost kernel: [ 2187.704561] [ 2042]     0  2042
1284       51   0       0             0 udisks-daemon
Oct 20 10:39:14 myhost kernel: [ 2187.704564] [ 2046]  1000  2046
63112     5378   0       0             0 nautilus
Oct 20 10:39:14 myhost kernel: [ 2187.704567] [ 2048]  1000  2048
9063      140   0       0             0 bonobo-activati
Oct 20 10:39:14 myhost kernel: [ 2187.704569] [ 2056]  1000  2056
43835     1188   1       0             0 wnck-applet
Oct 20 10:39:14 myhost kernel: [ 2187.704572] [ 2059]  1000  2059
42284      583   1       0             0 cpufreq-applet
Oct 20 10:39:14 myhost kernel: [ 2187.704574] [ 2062]  1000  2062
41008      336   1       0             0 notification-ar
Oct 20 10:39:14 myhost kernel: [ 2187.704577] [ 2063]  1000  2063
43602      924   0       0             0 mixer_applet2
Oct 20 10:39:14 myhost kernel: [ 2187.704580] [ 2065]  1000  2065
41469      369   0       0             0 multiload-apple
Oct 20 10:39:14 myhost kernel: [ 2187.704582] [ 2066]  1000  2066
45661      791   1       0             0 clock-applet
Oct 20 10:39:14 myhost kernel: [ 2187.704585] [ 2067]  1000  2067
1631       70   0       0             0 sh
Oct 20 10:39:14 myhost kernel: [ 2187.704587] [ 2069]  1000  2069
114532    41485   0       0             0 evolution
Oct 20 10:39:14 myhost kernel: [ 2187.704590] [ 2077]  1000  2077
6808      198   0       0             0 polkit-gnome-au
Oct 20 10:39:14 myhost kernel: [ 2187.704592] [ 2079]  1000  2079
8439     1599   0       0             0 applet.py
Oct 20 10:39:14 myhost kernel: [ 2187.704595] [ 2081]  1000  2081
10737      416   1       0             0 evolution-alarm
Oct 20 10:39:14 myhost kernel: [ 2187.704598] [ 2086]  1000  2086
5037      264   0       0             0 gdu-notificatio
Oct 20 10:39:14 myhost kernel: [ 2187.704600] [ 2087]  1000  2087
7018      287   1       0             0 gnome-power-man
Oct 20 10:39:14 myhost kernel: [ 2187.704603] [ 2088]  1000  2088
7574      291   0       0             0 vino-server
Oct 20 10:39:14 myhost kernel: [ 2187.704605] [ 2089]  1000  2089
72305      434   0       0             0 nm-applet
Oct 20 10:39:14 myhost kernel: [ 2187.704608] [ 2099]  1000  2099
7247      269   1       0             0 gnome-screensav
Oct 20 10:39:14 myhost kernel: [ 2187.704611] [ 2101]  1000  2101
15260      376   1       0             0 e-calendar-fact
Oct 20 10:39:14 myhost kernel: [ 2187.704613] [ 2110]  1000  2110
41625      995   1       0             0 notify-osd
Oct 20 10:39:14 myhost kernel: [ 2187.704616] [ 2113]  1000  2113
2414      276   0       0             0 gvfsd-trash
Oct 20 10:39:14 myhost kernel: [ 2187.704618] [ 2115]  1000  2115
1806      177   1       0             0 mission-control
Oct 20 10:39:14 myhost kernel: [ 2187.704621] [ 2118]     0  2118
3290       69   0       0             0 system-tools-ba
Oct 20 10:39:14 myhost kernel: [ 2187.704624] [ 2129]  1000  2129
2201      119   0       0             0 gvfsd-burn
Oct 20 10:39:14 myhost kernel: [ 2187.704626] [ 2133]     0  2133
3296     2216   1       0             0 SystemToolsBack
Oct 20 10:39:14 myhost kernel: [ 2187.704629] [ 2145]  1000  2145
2299      202   1       0             0 gvfsd-metadata
Oct 20 10:39:14 myhost kernel: [ 2187.704631] [ 2157]  1000  2157
22558      213   1       0             0 conky
Oct 20 10:39:14 myhost kernel: [ 2187.704634] [ 2189]  1000  2189
43833     1183   1       0             0 gnome-terminal
Oct 20 10:39:14 myhost kernel: [ 2187.704636] [ 2191]  1000  2191
450       29   1       0             0 gnome-pty-helpe
Oct 20 10:39:14 myhost kernel: [ 2187.704639] [ 2193]  1000  2193
2041      451   1       0             0 bash
Oct 20 10:39:14 myhost kernel: [ 2187.704641] [ 2205]  1000  2205
1480       36   1       0             0 su
Oct 20 10:39:14 myhost kernel: [ 2187.704644] [ 2206]     0  2206
2041      476   1       0             0 bash
Oct 20 10:39:14 myhost kernel: [ 2187.704646] [ 2277]     0  2277
1487       43   1       0             0 sudo
Oct 20 10:39:14 myhost kernel: [ 2187.704649] [ 2278]     0  2278
55057     3431   0       0             0 gedit
Oct 20 10:39:14 myhost kernel: [ 2187.704651] [ 2282]     0  2282
794       43   1       0             0 dbus-launch
Oct 20 10:39:14 myhost kernel: [ 2187.704654] [ 2283]     0  2283
593       51   0       0             0 dbus-daemon
Oct 20 10:39:14 myhost kernel: [ 2187.704657] [ 2286]     0  2286
2590      412   1       0             0 gconfd-2
Oct 20 10:39:14 myhost kernel: [ 2187.704659] [ 2319]  1000  2319
151661     1891   1       0             0 stardict
Oct 20 10:39:14 myhost kernel: [ 2187.704662] [ 2403]  1000  2403
104374    21095   0       0             0 firefox
Oct 20 10:39:14 myhost kernel: [ 2187.704664] [ 2478]  1000  2478
23809     2021   1       0             0 plugin-containe
Oct 20 10:39:14 myhost kernel: [ 2187.704667] [ 2487]  1000  2487
9147     1263   0       0             0 GoogleTalkPlugi
Oct 20 10:39:14 myhost kernel: [ 2187.704669] [ 2614]  1000  2614
5541      191   0       0             0 dconf-service
Oct 20 10:39:14 myhost kernel: [ 2187.704672] [ 2658]  1000  2658
57278     7232   1       0             0 skype
Oct 20 10:39:14 myhost kernel: [ 2187.704674] [ 2784]  1000  2784
9883      327   0       0             0 gvfsd-smb
Oct 20 10:39:14 myhost kernel: [ 2187.704677] [ 2796]  1000  2796
2067      479   0       0             0 bash
Oct 20 10:39:14 myhost kernel: [ 2187.704680] [ 2882]  1000  2882
50484     3098   1       0             0 gedit
Oct 20 10:39:14 myhost kernel: [ 2187.704682] [ 3319]  1000  3319
1480       36   1       0             0 su
Oct 20 10:39:14 myhost kernel: [ 2187.704685] [ 3320]     0  3320
2041      478   1       0             0 bash
Oct 20 10:39:14 myhost kernel: [ 2187.704687] [ 3436]  1000  3436
63059    15539   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704690] [ 3440]  1000  3440
5483      118   0       0             0 evinced
Oct 20 10:39:14 myhost kernel: [ 2187.704692] [ 3446]  1000  3446
67154    29031   0       0             0 acroread
Oct 20 10:39:14 myhost kernel: [ 2187.704695] [ 3498]  1000  3498
64269    15735   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704698] [ 3506]  1000  3506
1631       66   1       0             0 foxitreader
Oct 20 10:39:14 myhost kernel: [ 2187.704700] [ 3508]  1000  3508
11968     4007   1       0             0 FoxitReader
Oct 20 10:39:14 myhost kernel: [ 2187.704703] [ 3564]  1000  3564
65198    17404   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704705] [ 3622]  1000  3622
62247    14779   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704708] [ 3692]  1000  3692
64126    14386   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704710] [ 3708]  1000  3708
61564    13580   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704713] [ 3770]  1000  3770
63902    16011   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704715] [ 3889]  1000  3889
67617    19788   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704718] [ 3903]  1000  3903
77057    23319   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704720] [ 3927]  1000  3927
60335    14994   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704723] [ 3940]  1000  3940
63049    15434   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704725] [ 3954]  1000  3954
65562    17479   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704727] [ 3972]  1000  3972
64697    16979   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704730] [ 4002]  1000  4002
59109    13305   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704733] [ 4015]  1000  4015
64456    16434   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704735] [ 4028]  1000  4028
63322    15376   0       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704738] [ 4081]  1000  4081
59547    13587   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704740] [ 4085]     0  4085
717       36   0       0             0 sh
Oct 20 10:39:14 myhost kernel: [ 2187.704743] [ 4086]     0  4086
717       36   0       0             0 sh
Oct 20 10:39:14 myhost kernel: [ 2187.704745] [ 4089]     0  4089
717       35   1       0             0 sh
Oct 20 10:39:14 myhost kernel: [ 2187.704748] [ 4092]     0  4092
1185       43   0       0             0 git
Oct 20 10:39:14 myhost kernel: [ 2187.704750] [ 4093]     0  4093
1185       42   1       0             0 git
Oct 20 10:39:14 myhost kernel: [ 2187.704753] [ 4096]     0  4096
717       55   0       0             0 git-pull
Oct 20 10:39:14 myhost kernel: [ 2187.704755] [ 4097]     0  4097
717       54   1       0             0 git-pull
Oct 20 10:39:14 myhost kernel: [ 2187.704758] [ 4128]     0  4128
1187       58   0       0             0 git
Oct 20 10:39:14 myhost kernel: [ 2187.704760] [ 4129]     0  4129
1187       58   1       0             0 git
Oct 20 10:39:14 myhost kernel: [ 2187.704763] [ 4130]     0  4130
1571       86   1       0             0 ssh
Oct 20 10:39:14 myhost kernel: [ 2187.704765] [ 4131]     0  4131
1571       87   0       0             0 ssh
Oct 20 10:39:14 myhost kernel: [ 2187.704767] [ 4141]  1000  4141
65072    15280   1       0             0 evince
Oct 20 10:39:14 myhost kernel: [ 2187.704771] =================
Oct 20 10:39:14 myhost kernel: [ 2187.704773] oom_kill_process:kill task
pid=2069, victim_points=0
Oct 20 10:39:14 myhost kernel: [ 2187.704776]
oom_kill_task:=========kill task pid=2069




here is the page-types log:
             flags	page-count       MB  symbolic-flags
long-symbolic-flags
0x0000000000000000	     17478       68
__________________________________	
0x0000000100000000	      8264       32
______________________r___________	reserved
0x0000000000010000	      2812       10
________________T_________________	compound_tail
0x0000000000008000	        76        0
_______________H__________________	compound_head
0x0000008000000000	         1        0
_____________________________c____	uncached
0x0000000400000001	         3        0
L_______________________d_________	locked,mappedtodisk
0x0000000400000008	         1        0
___U____________________d_________	uptodate,mappedtodisk
0x0000000400000021	        12        0
L____l__________________d_________	locked,lru,mappedtodisk
0x0000000800000024	       718        2
__R__l___________________P________	referenced,lru,private
0x0000000400000028	      2183        8
___U_l__________________d_________	uptodate,lru,mappedtodisk
0x0001000400000028	         4        0
___U_l__________________d_____I___	uptodate,lru,mappedtodisk,readahead
0x000000040000002c	        67        0
__RU_l__________________d_________	referenced,uptodate,lru,mappedtodisk
0x000000000000002c	         4        0
__RU_l____________________________	referenced,uptodate,lru
0x000000080000002c	      2169        8
__RU_l___________________P________	referenced,uptodate,lru,private
0x000000000000402c	      3939       15
__RU_l________b___________________	referenced,uptodate,lru,swapbacked
0x0000000000004038	         1        0
___UDl________b___________________	uptodate,dirty,lru,swapbacked
0x000000000000403c	        71        0
__RUDl________b___________________
referenced,uptodate,dirty,lru,swapbacked
0x000000080000003c	         1        0
__RUDl___________________P________	referenced,uptodate,dirty,lru,private
0x0000000800000060	       107        0
_____lA__________________P________	lru,active,private
0x0000000800000064	       228        0
__R__lA__________________P________	referenced,lru,active,private
0x0000000c00000068	         8        0
___U_lA_________________dP________
uptodate,lru,active,mappedtodisk,private
0x0000000000000068	        16        0
___U_lA___________________________	uptodate,lru,active
0x0000000800000068	       331        1
___U_lA__________________P________	uptodate,lru,active,private
0x0000000400000068	         7        0
___U_lA_________________d_________	uptodate,lru,active,mappedtodisk
0x000000000000006c	        26        0
__RU_lA___________________________	referenced,uptodate,lru,active
0x000000080000006c	        21        0
__RU_lA__________________P________
referenced,uptodate,lru,active,private
0x000000040000006c	       142        0
__RU_lA_________________d_________
referenced,uptodate,lru,active,mappedtodisk
0x0000000000004078	     14103       55
___UDlA_______b___________________	uptodate,dirty,lru,active,swapbacked
0x000000000000407c	      4277       16
__RUDlA_______b___________________
referenced,uptodate,dirty,lru,active,swapbacked
0x0004000000008080	        66        0
_______S_______H________________A_	slab,compound_head,slub_frozen
0x0000000000000080	      2556        9
_______S__________________________	slab
0x0000000000008080	       794        3
_______S_______H__________________	slab,compound_head
0x0004000000000080	        51        0
_______S________________________A_	slab,slub_frozen
0x000000080000012c	         2        0
__RU_l__W________________P________
referenced,uptodate,lru,writeback,private
0x0000000000000400	      1719        6
__________B_______________________	buddy
0x0000000000000800	         1        0
___________M______________________	mmap
0x0000000000000804	         2        0
__R________M______________________	referenced,mmap
0x0000000400000808	         1        0
___U_______M____________d_________	uptodate,mmap,mappedtodisk
0x0000000000000810	         1        0
____D______M______________________	dirty,mmap
0x0000000000008814	         1        0
__R_D______M___H__________________	referenced,dirty,mmap,compound_head
0x0000000000010814	        15        0
__R_D______M____T_________________	referenced,dirty,mmap,compound_tail
0x0000000400000828	       805        3
___U_l_____M____________d_________	uptodate,lru,mmap,mappedtodisk
0x000000040000082c	       467        1
__RU_l_____M____________d_________
referenced,uptodate,lru,mmap,mappedtodisk
0x000000000000482c	         1        0
__RU_l_____M__b___________________
referenced,uptodate,lru,mmap,swapbacked
0x0000000000004838	      5039       19
___UDl_____M__b___________________	uptodate,dirty,lru,mmap,swapbacked
0x000000000000483c	       126        0
__RUDl_____M__b___________________
referenced,uptodate,dirty,lru,mmap,swapbacked
0x000000020004483c	         1        0
__RUDl_____M__b___u____m__________
referenced,uptodate,dirty,lru,mmap,swapbacked,unevictable,mlocked
0x0000000400000868	         9        0
___U_lA____M____________d_________	uptodate,lru,active,mmap,mappedtodisk
0x000000040000086c	      3743       14
__RU_lA____M____________d_________
referenced,uptodate,lru,active,mmap,mappedtodisk
0x0000000c0000086c	         7        0
__RU_lA____M____________dP________
referenced,uptodate,lru,active,mmap,mappedtodisk,private
0x0000000000004878	       581        2
___UDlA____M__b___________________
uptodate,dirty,lru,active,mmap,swapbacked
0x000000000000487c	        89        0
__RUDlA____M__b___________________
referenced,uptodate,dirty,lru,active,mmap,swapbacked
0x0000000000005008	         8        0
___U________a_b___________________	uptodate,anonymous,swapbacked
0x0000000000005808	         4        0
___U_______Ma_b___________________	uptodate,mmap,anonymous,swapbacked
0x0000000000005828	     83024      324
___U_l_____Ma_b___________________
uptodate,lru,mmap,anonymous,swapbacked
0x000000000000582c	        99        0
__RU_l_____Ma_b___________________
referenced,uptodate,lru,mmap,anonymous,swapbacked
0x000000020004582c	         8        0
__RU_l_____Ma_b___u____m__________
referenced,uptodate,lru,mmap,anonymous,swapbacked,unevictable,mlocked
0x0000000000005838	         2        0
___UDl_____Ma_b___________________
uptodate,dirty,lru,mmap,anonymous,swapbacked
0x0000000000005868	    358737     1401
___U_lA____Ma_b___________________
uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c	        42        0
__RU_lA____Ma_b___________________
referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total	    515071     2011


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

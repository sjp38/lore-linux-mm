Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C6D3C8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 03:11:00 -0500 (EST)
Received: by bwz17 with SMTP id 17so6068829bwz.14
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 00:10:57 -0800 (PST)
Message-ID: <4D75E4E6.9020507@gmail.com>
Date: Tue, 08 Mar 2011 11:12:22 +0300
From: Andrew Vagin <avagin@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>	<20110305152056.GA1918@barrios-desktop>	<4D72580D.4000208@gmail.com>	<20110305155316.GB1918@barrios-desktop>	<4D7267B6.6020406@gmail.com>	<20110305170759.GC1918@barrios-desktop>	<20110307135831.9e0d7eaa.akpm@linux-foundation.org> <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, All
> I agree with Minchan and can't think this is a real fix....
> Andrey, I'm now trying your fix and it seems your fix for oom-killer,
> 'skip-zombie-process' works enough good for my environ.
>
> What is your enviroment ? number of cpus ? architecture ? size of memory ?
Processort: AMD Phenom(tm) II X6 1055T Processor (six-core)
Ram: 8Gb
RHEL6, x86_64. This host doesn't have swap.

It hangs up fast. Tomorrow I will have to send a processes state, if it 
will be interesting for you. With my patch the kernel work fine. I added 
debug and found that it hangs up in the described case.
I suppose that my patch may be incorrect, but the problem exists and we 
should do something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

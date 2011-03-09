Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 73F3C8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:13:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B25093EE0BC
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:13:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9833045DE53
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:13:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8130D45DE51
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:13:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 70BBC1DB802F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:13:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31D4B1DB8037
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:13:16 +0900 (JST)
Date: Wed, 9 Mar 2011 15:06:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110309150656.c7128fdd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D75E4E6.9020507@gmail.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
	<4D75E4E6.9020507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 08 Mar 2011 11:12:22 +0300
Andrew Vagin <avagin@gmail.com> wrote:

> Hi, All
> > I agree with Minchan and can't think this is a real fix....
> > Andrey, I'm now trying your fix and it seems your fix for oom-killer,
> > 'skip-zombie-process' works enough good for my environ.
> >
> > What is your enviroment ? number of cpus ? architecture ? size of memory ?
> Processort: AMD Phenom(tm) II X6 1055T Processor (six-core)
> Ram: 8Gb
> RHEL6, x86_64. This host doesn't have swap.
> 
Ok, thanks. "NO SWAP" is a big information ;)

> It hangs up fast. Tomorrow I will have to send a processes state, if it 
> will be interesting for you. With my patch the kernel work fine. I added 
> debug and found that it hangs up in the described case.
> I suppose that my patch may be incorrect, but the problem exists and we 
> should do something.
>

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

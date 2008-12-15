Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kvack.org (Postfix) with SMTP id BF4CA6B0060
	for <linux-mm@kvack.org>; Sun, 14 Dec 2008 21:04:12 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBF25REX013040
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Dec 2008 11:05:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E46A245DE53
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 11:05:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD15245DE55
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 11:05:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 35CC41DB8013
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 11:05:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 715681DB8023
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 11:05:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.28-rc8 big regression in VM
In-Reply-To: <20081215011645.GA9707@localhost>
References: <20081213095815.GA7143@ics.muni.cz> <20081215011645.GA9707@localhost>
Message-Id: <20081215110231.00DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Dec 2008 11:05:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Lukas

(cc to linux-mm)

> On Sat, Dec 13, 2008 at 11:58:15AM +0200, Lukas Hejtmanek wrote:
> > On Sat, Dec 13, 2008 at 09:21:15AM +0800, Wu Fengguang wrote:
> > > I cannot reproduce it on 2.6.28-rc7, compiling 2.6.28-rc8...
> > > 
> > > # free; echo 3 > /proc/sys/vm/drop_caches; free
> > >              total       used       free     shared    buffers     cached
> > > Mem:          1940        109       1831          0          0         42
> > > -/+ buffers/cache:         66       1873
> > > Swap:            0          0          0
> > >              total       used       free     shared    buffers     cached
> > > Mem:          1940         62       1877          0          0          7
> > > -/+ buffers/cache:         55       1884
> > > Swap:            0          0          0
> > > 
> > > > once the whole memory is eaten by the cache, the system is pretty unusable.
> > > 
> > > What's your kconfig?
> > 
> > attached.

I also don't reproduce your problem.
Could you get output of "cat /proc/meminfo", not only free command?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

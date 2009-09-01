Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 985156B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 06:12:12 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n81ACDZP013995
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 19:12:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 02A0045DE4F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 19:12:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C77F545DE4E
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 19:12:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A3273E1800E
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 19:12:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A929E1800D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 19:12:12 +0900 (JST)
Date: Tue, 1 Sep 2009 19:10:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][BUG] free is bigger than presnet Re: mmotm
 2009-08-27-16-51 uploaded
Message-Id: <20090901191018.19a69696.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090901185013.c86bd937.kamezawa.hiroyu@jp.fujitsu.com>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
	<20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0909011031140.13740@sister.anvils>
	<20090901185013.c86bd937.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 18:50:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 1 Sep 2009 10:33:31 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:
> > > 
> > > I'm not digggin so much but /proc/meminfo corrupted.
> > > 
> > > [kamezawa@bluextal cgroup]$ cat /proc/meminfo
> > > MemTotal:       24421124 kB
> > > MemFree:        38314388 kB
> > 
> > If that's without my fix to shrink_active_list(), I'd try again with.
> > Hugh
> > 
> Thank you very much. I missed this patch.
> It's fixed.

Sorry again, at continuing tests...thre are still..

MemTotal:       24421124 kB
MemFree:        25158956 kB
Buffers:            2264 kB
Cached:            34936 kB
SwapCached:         5140 kB

I wonder I miss something..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

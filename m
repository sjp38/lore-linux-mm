Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B574F6B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:43:52 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S7iVdg017436
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 16:44:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A379145DE54
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 16:44:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 82CBA45DE52
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 16:44:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F67BE08005
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 16:44:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A0C3AE08009
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 16:44:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <20090428072619.GA29747@eskimo.com>
References: <20090428154835.EBC9.A69D9226@jp.fujitsu.com> <20090428072619.GA29747@eskimo.com>
Message-Id: <20090428164050.EBD2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 16:44:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 28, 2009 at 03:52:29PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > 3. cache limitation of memcgroup solve this problem?
> > > 
> > > I was unable to get this to work -- do you have some documentation handy?
> > 
> > Do you have kernel source tarball?
> > Documentation/cgroups/memory.txt explain usage kindly.
> 
> Thank you.  My documentation was out of date.
> 
> I created a cgroup with limited memory and placed a copy command in it, and the
> latency problem seems to essentially go away.  However, I'm also a bit
> suspicious that my test might have become invalid, since my IO performance
> seems to have dropped somewhat too.
> 
> So, am I right in concluding that this more or less implicates bad page
> replacement as the culprit?  After I dropped vm caches and let my working set
> re-form, the memory cgroup seems to be effective at keeping a large pool of
> memory free from file pressure.

Hmm..
it seems your result mean bad page replacement occur. but actually
I hevn't seen such result on my environment.

Hmm, I think I need to make reproduce environmet to your trouble.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

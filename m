Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 32EE18D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:56:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB22uNJ6000843
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Dec 2010 11:56:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E1BE45DE5A
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:56:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 552C945DE56
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:56:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E62E38001
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:56:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DEC9E08001
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:56:23 +0900 (JST)
Date: Thu, 2 Dec 2010 11:50:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-Id: <20101202115036.1a4a42b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101202102110.157F.A69D9226@jp.fujitsu.com>
References: <20101130142509.4f49d452.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1012010859020.2849@router.home>
	<20101202102110.157F.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  2 Dec 2010 10:22:16 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Tue, 30 Nov 2010, Andrew Morton wrote:
> > 
> > > > +#define UNMAPPED_PAGE_RATIO 16
> > >
> > > Well.  Giving 16 a name didn't really clarify anything.  Attentive
> > > readers will want to know what this does, why 16 was chosen and what
> > > the effects of changing it will be.
> > 
> > The meaning is analoguous to the other zone reclaim ratio. But yes it
> > should be justified and defined.
> > 
> > > > Reviewed-by: Christoph Lameter <cl@linux.com>
> > >
> > > So you're OK with shoving all this flotsam into 100,000,000 cellphones?
> > > This was a pretty outrageous patchset!
> > 
> > This is a feature that has been requested over and over for years. Using
> > /proc/vm/drop_caches for fixing situations where one simply has too many
> > page cache pages is not so much fun in the long run.
> 
> I'm not against page cache limitation feature at all. But, this is
> too ugly and too destructive fast path. I hope this patch reduce negative
> impact more.
> 

And I think min_mapped_unmapped_pages is ugly. It should be
"unmapped_pagecache_limit" or some because it's for limitation feature.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

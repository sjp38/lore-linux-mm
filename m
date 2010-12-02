Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB4958D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:22:19 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB21MH6T026673
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 10:22:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ADEF45DE6D
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:22:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2421D45DE55
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:22:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12DE71DB803C
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:22:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD8D01DB803E
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:22:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
In-Reply-To: <alpine.DEB.2.00.1012010859020.2849@router.home>
References: <20101130142509.4f49d452.akpm@linux-foundation.org> <alpine.DEB.2.00.1012010859020.2849@router.home>
Message-Id: <20101202102110.157F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Dec 2010 10:22:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 30 Nov 2010, Andrew Morton wrote:
> 
> > > +#define UNMAPPED_PAGE_RATIO 16
> >
> > Well.  Giving 16 a name didn't really clarify anything.  Attentive
> > readers will want to know what this does, why 16 was chosen and what
> > the effects of changing it will be.
> 
> The meaning is analoguous to the other zone reclaim ratio. But yes it
> should be justified and defined.
> 
> > > Reviewed-by: Christoph Lameter <cl@linux.com>
> >
> > So you're OK with shoving all this flotsam into 100,000,000 cellphones?
> > This was a pretty outrageous patchset!
> 
> This is a feature that has been requested over and over for years. Using
> /proc/vm/drop_caches for fixing situations where one simply has too many
> page cache pages is not so much fun in the long run.

I'm not against page cache limitation feature at all. But, this is
too ugly and too destructive fast path. I hope this patch reduce negative
impact more.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

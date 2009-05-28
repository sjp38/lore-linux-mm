Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E5D7B6B004D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 00:30:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S4URlX002754
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 28 May 2009 13:30:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A06D45DE62
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:30:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED2F045DE57
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:30:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C53E01DB8041
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:30:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EF761DB803F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:30:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] zone_reclaim is always 0 by default
In-Reply-To: <20090527095006.GE29447@sgi.com>
References: <20090527164549.68B4.A69D9226@jp.fujitsu.com> <20090527095006.GE29447@sgi.com>
Message-Id: <20090528132800.F0F5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 28 May 2009 13:30:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Wed, May 27, 2009 at 05:06:18PM +0900, KOSAKI Motohiro wrote:
> > your last patch is one of considerable thing. but it has one weakness.
> > in general "ifdef x86" is wrong idea. almost minor architecture don't
> > have sufficient tester. the difference against x86 often makes bug.
> > Then, unnecessary difference is hated by much people.
> 
> Let me start by saying I can barely understand this entire email.
> I appreciate that english is a second language for you and you are
> doing a service to the linux community with your contributions despite
> the language barrier.  I commend you for your efforts.  I do ask that if
> there was more information contained in your email than I am replying too,
> please reword it so I may understand.
> 
> IIRC, my last patch made it an arch header option to set zone_reclaim_mode
> to any value it desired while leaving the default as 1.  The only arch
> that changed the default was x86 (both 32 and 64 bit).  That seems the
> least disruptive to existing users.
> 
> > So, I think we have two selectable choice.
> > 
> > 1. remove zone_reclaim default setting completely (this patch)
> > 2. Only PowerPC and IA64 have default zone_reclaim_mode settings,
> >    other architecture always use zone_reclaim_mode=0.
> 
> Looks like 2 is the inverse of my patch.  That is fine as well.  The only
> reason I formed the patch with the default of 1 and override on x86 is
> it was one less line of change and one less file.

OK. I appreciate we reach good agreement.
I'll try make patch (2) in this week end.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

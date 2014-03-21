Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDA6B0281
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 18:07:01 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so2938607pab.34
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:07:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m8si4173915pbd.288.2014.03.21.15.06.59
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 15:07:00 -0700 (PDT)
Date: Fri, 21 Mar 2014 15:06:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: numa: Recheck for transhuge pages under lock during
 protection changes
Message-Id: <20140321150658.386926ac3afa263946b1a2aa@linux-foundation.org>
In-Reply-To: <20140319143831.GA4751@suse.de>
References: <20140307182745.GD1931@suse.de>
	<20140311162845.GA30604@suse.de>
	<531F3F15.8050206@oracle.com>
	<531F4128.8020109@redhat.com>
	<531F48CC.303@oracle.com>
	<20140311180652.GM10663@suse.de>
	<531F616A.7060300@oracle.com>
	<20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
	<20140312103602.GN10663@suse.de>
	<5323C5D9.2070902@oracle.com>
	<20140319143831.GA4751@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Mar 2014 14:38:32 +0000 Mel Gorman <mgorman@suse.de> wrote:

> On Fri, Mar 14, 2014 at 11:15:37PM -0400, Sasha Levin wrote:
> > On 03/12/2014 06:36 AM, Mel Gorman wrote:
> > >Andrew, this should go with the patches
> > >mmnuma-reorganize-change_pmd_range.patch
> > >mmnuma-reorganize-change_pmd_range-fix.patch
> > >move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
> > >in mmotm please.
> > >
> > >Thanks.
> > >
> > >---8<---
> > >From: Mel Gorman<mgorman@suse.de>
> > >Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes
> > >
> > >Sasha Levin reported the following bug using trinity
> > 
> > I'm seeing a different issue with this patch. A NULL ptr deref occurs in the
> > pte_offset_map_lock() macro right before the new recheck code:
> > 
> 
> This on top?
> 
> I tried testing it but got all sorts of carnage that trinity throw up
> in the mix and ordinary testing does not trigger the race. I've no idea
> which of the current mess of trinity-exposed bugs you've encountered and
> got fixed already.
> 

Where are we at with this one?


With this patch I'm now sitting on

mmnuma-reorganize-change_pmd_range.patch
mmnuma-reorganize-change_pmd_range-fix.patch
mm-numa-recheck-for-transhuge-pages-under-lock-during-protection-changes.patch
mm-numa-recheck-for-transhuge-pages-under-lock-during-protection-changes-fix.patch
move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch

Where the first four are prep work for the fifth.

move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
is a performance optimisation for KVM guests.  Should I drop all five,
try again next time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

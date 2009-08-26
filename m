Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67D0F6B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:00:26 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n7QM0LC9025780
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 23:00:21 +0100
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by zps36.corp.google.com with ESMTP id n7QM0FD4022311
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:00:16 -0700
Received: by pxi33 with SMTP id 33so543310pxi.11
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:00:15 -0700 (PDT)
Date: Wed, 26 Aug 2009 15:00:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090826211400.GE14722@random.random>
Message-ID: <alpine.DEB.2.00.0908261457140.12052@chino.kir.corp.google.com>
References: <20090825145832.GP14722@random.random> <20090825152217.GQ14722@random.random> <Pine.LNX.4.64.0908251836050.30372@sister.anvils> <20090825181019.GT14722@random.random> <Pine.LNX.4.64.0908251958170.5871@sister.anvils> <20090825194530.GU14722@random.random>
 <Pine.LNX.4.64.0908261910530.15622@sister.anvils> <20090826194444.GB14722@random.random> <Pine.LNX.4.64.0908262048270.21188@sister.anvils> <4A95A10C.5040008@redhat.com> <20090826211400.GE14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Andrea Arcangeli wrote:

> In oom deadlock terms madvise(UNMERGEABLE) is the only place that is
> 100% fine at breaking KSM pages, because it runs with right tsk->mm
> and page allocation will notice TIF_MEMDIE set on tsk.
> 

Be aware that the page allocator in Linus' git will not notice TIF_MEMDIE 
for current if that task is chosen for oom kill since alloc_flags are not 
updated for that particular allocation.  My patch in -mm,
mm-update-alloc_flags-after-oom-killer-has-been-called.patch, fixes that 
but is not yet merged (I assume it's on hold for 2.6.32?).

I'd hate for you to run into this in testing and spend time debugging it 
when the problem already has a fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

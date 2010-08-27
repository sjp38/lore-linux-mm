Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B98B6B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:33:51 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7RLXnpY025770
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:33:50 -0700
Received: from vws16 (vws16.prod.google.com [10.241.21.144])
	by hpaq13.eem.corp.google.com with ESMTP id o7RLXQ1K018136
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:33:35 -0700
Received: by vws16 with SMTP id 16so4216686vws.0
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 14:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTim16oT13keYK_oz=7kmDmdG=ADfkGXMKp3_dEw_@mail.gmail.com>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100826235052.GZ6803@random.random>
	<AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
	<20100827095546.GC6803@random.random>
	<AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
	<alpine.DEB.2.00.1008271159160.18495@router.home>
	<AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com>
	<alpine.DEB.2.00.1008271420400.18495@router.home>
	<AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
	<alpine.DEB.2.00.1008271547200.22988@router.home>
	<AANLkTim16oT13keYK_oz=7kmDmdG=ADfkGXMKp3_dEw_@mail.gmail.com>
Date: Fri, 27 Aug 2010 14:33:35 -0700
Message-ID: <AANLkTikML=HghpOVK0WZ0t6CRaNOKvu=57ebojZ+YCNS@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, I seem to have hit some key which sent the mail off too soon, a
tab perhaps: finishing up...

On Fri, Aug 27, 2010 at 2:28 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, Aug 27, 2010 at 1:56 PM, Christoph Lameter <cl@linux.com> wrote:
>>
>>> of that second check, then we know that we got the right anon_vma,
>>
>> I do not see a second check (*after* taking the lock) in the patch

        if (page_mapped(page))
                return anon_vma;

>> and the way the lock is taken can be a problem in itself.

No, that's what we rely upon SLAB_DESTROY_BY_RCU for.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

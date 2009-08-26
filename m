Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0DB916B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:28:36 -0400 (EDT)
Date: Wed, 26 Aug 2009 22:28:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
Message-ID: <20090826202843.GC14722@random.random>
References: <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random>
 <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random>
 <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
 <20090825194530.GU14722@random.random>
 <Pine.LNX.4.64.0908261910530.15622@sister.anvils>
 <20090826194444.GB14722@random.random>
 <Pine.LNX.4.64.0908262048270.21188@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908262048270.21188@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 26, 2009 at 08:57:27PM +0100, Hugh Dickins wrote:
> that might be useful.  But KSM_RUN_UNMERGE wouldn't be able to use_mm
> since it's coming from a normal user process - perhaps it should be a
> kill-me-first like swapoff via PF_SWAPOFF.

That would sound just perfect if only there wasn't also a break_cow in
the kksmd context that will trigger page allocation as it can't
takeover the KSM page like it would normally be guaranteed to do for a
cow on a regular anon page mapped readonly in the pte after read
swapin for example. Still for the echo 2 kill me first definitely
makes sense, so maybe we should differentiate the two cases (kksmd and
sysfs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

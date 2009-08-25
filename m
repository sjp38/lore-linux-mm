Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B3DDC6B00A9
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:28 -0400 (EDT)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKGSj1026312
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:28 -0400
Date: Tue, 25 Aug 2009 20:10:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
Message-ID: <20090825181019.GT14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random>
 <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 06:49:09PM +0100, Hugh Dickins wrote:
> Sorry, I just don't get it.  How does down_read here help?
> Perhaps you thought ksm.c had down_write of mmap_sem in all cases?
> 
> No, and I don't think we want to change its down_reads to down_writes.

Looking ksm.c it should have been down_write indeed...

> Nor do we want to change your down_read here to down_write, that will
> just reintroduce the OOM deadlock that 9/12 was about solving.

I'm not sure anymore I get what this fix is about... mm_users is
allowed to go to 0. If mm_users is allowed to go to 0, it's up to ksm
to check inside its inner loops that mm_users is 0 and bail
out. Bailing out it will unblock exit so that exit_mmap can run. What
exactly is the unfixable issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

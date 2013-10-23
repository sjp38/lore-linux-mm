Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A61866B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 05:30:53 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so778049pdj.31
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:30:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id cj2si1459932pbc.177.2013.10.23.02.30.51
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 02:30:52 -0700 (PDT)
Received: by mail-ea0-f170.google.com with SMTP id q10so226230eaj.1
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:30:50 -0700 (PDT)
Date: Wed, 23 Oct 2013 02:30:45 -0700
From: walken@google.com
Subject: Re: [PATCH 1/3] mm: add mlock_future_check helper
Message-ID: <20131023093045.GA2862@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
 <1382057438-3306-2-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382057438-3306-2-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Oct 17, 2013 at 05:50:36PM -0700, Davidlohr Bueso wrote:
> Both do_brk and do_mmap_pgoff verify that we actually
> capable of locking future pages if the corresponding
> VM_LOCKED flags are used. Encapsulate this logic into
> a single mlock_future_check() helper function.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michel Lespinasse <walken@google.com>

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

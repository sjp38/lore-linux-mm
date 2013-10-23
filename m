Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CC8FB6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 05:33:59 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so625620pdj.20
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:33:59 -0700 (PDT)
Received: from psmtp.com ([74.125.245.196])
        by mx.google.com with SMTP id gu5si14919267pac.14.2013.10.23.02.33.58
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 02:33:58 -0700 (PDT)
Received: by mail-ea0-f175.google.com with SMTP id m14so274837eaj.20
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:33:56 -0700 (PDT)
Date: Wed, 23 Oct 2013 02:33:52 -0700
From: walken@google.com
Subject: Re: [PATCH 2/3] mm/mlock: prepare params outside critical region
Message-ID: <20131023093352.GB2862@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
 <1382057438-3306-3-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382057438-3306-3-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Thu, Oct 17, 2013 at 05:50:37PM -0700, Davidlohr Bueso wrote:
> All mlock related syscalls prepare lock limits, lengths and
> start parameters with the mmap_sem held. Move this logic
> outside of the critical region. For the case of mlock, continue
> incrementing the amount already locked by mm->locked_vm with
> the rwsem taken.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

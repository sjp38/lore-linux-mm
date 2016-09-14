Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 831FA6B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 05:25:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so7934467wmz.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 02:25:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gd8si3269508wjb.188.2016.09.14.02.25.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 02:25:54 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:25:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] sched,numa,mm: revert to checking pmd/pte_write instead
 of VMA flags
Message-ID: <20160914092551.GA2745@suse.de>
References: <20160908213053.07c992a9@annuminas.surriel.com>
 <20160911162402.GA2775@suse.de>
 <1473692983.32433.235.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1473692983.32433.235.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, aarcange@redhat.com

On Mon, Sep 12, 2016 at 11:09:43AM -0400, Rik van Riel wrote:
> > Patch looks ok other than the comment above the second hunk being out
> > of
> > date. Out of curiousity, what workload benefitted from this? I saw a
> > mix
> > of marginal results when I ran this on a 2-socket and 4-socket box.
> 
> I did not performance test the change, because I believe
> the VM_WRITE test has a small logical error.
> 
> Specifically, VM_WRITE is also true for VMAs that are
> PROT_WRITE|MAP_PRIVATE, which we do NOT want to group
> on. Every shared library mapped on my system seems to
> have a (small) read-write VMA:
> 

Ok, while I agree with you, the patch is not a guaranteed win. However,
in the event it is not, I agree that the problem will be with the
grouping code. If the comment is updated then feel free to add my

Acked-by: Mel Gorman <mgorman@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

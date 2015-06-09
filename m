Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE7E6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 12:49:16 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so17318413pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 09:49:16 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ts9si9647622pab.90.2015.06.09.09.49.14
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 09:49:15 -0700 (PDT)
Message-ID: <55771909.2020005@intel.com>
Date: Tue, 09 Jun 2015 09:49:13 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com> <20150609084739.GQ26425@suse.de> <20150609103231.GA11026@gmail.com> <20150609112055.GS26425@suse.de> <20150609124328.GA23066@gmail.com> <5577078B.2000503@intel.com>
In-Reply-To: <5577078B.2000503@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 06/09/2015 08:34 AM, Dave Hansen wrote:
> 2. We should measure flushing of ascending, adjacent virtual addresses
>    mapped with 4k pages since that is the normal case.  Perhaps
>    vmalloc(16MB) or something.

Now that I think about this a bit more, we really have two different
patterns here:
1. flush_tlb_mm_range() style, which is contiguous virtual address
   flushing from an unmap-style operation.
2. Mel's new try_to_unmap_one() style, which are going to be relatively
   random virtual addresses.

So, the "ascending adjacent" case is still interesting, but it wouldn't
cover Mel's new case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9336B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 17:34:44 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so1347654pab.34
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:34:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tm9si3481097pab.337.2014.02.28.14.34.41
        for <linux-mm@kvack.org>;
        Fri, 28 Feb 2014 14:34:41 -0800 (PST)
Date: Fri, 28 Feb 2014 14:34:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if
 they are in page cache
Message-Id: <20140228143440.e0ec026baeced2efbb52aa50@linux-foundation.org>
In-Reply-To: <1393625931-2858-1-git-send-email-quning@google.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri, 28 Feb 2014 14:18:50 -0800 Ning Qu <quning@google.com> wrote:

> This is a follow-up patch for "mm: map few pages around fault address if they are in page cache"
> 
> We use the generic filemap_map_pages as ->map_pages in shmem/tmpfs.
> 

Please cc Hugh on shmem/tmpfs things

> 
> =========================================================================
> Below is just some simple experiment numbers from this patch, let me know if
> you would like more:
> 
> Tested on Xeon machine with 64GiB of RAM, using the current default fault
> order 4.
> 
> Sequential access 8GiB file
> 			Baseline 	with-patch
> 1 thread
>     minor fault		205		101	

Confused.  Sequential access of an 8G file should generate 2,000,000
minor faults, not 205.  And with FAULT_AROUND_ORDER=4, that should come
down to 2,000,000/16 minor faults when using faultaround?

>     time, seconds	7.94		7.82
> 
> Random access 8GiB file
> 			Baseline 	with-patch
> 1 thread
>     minor fault		724		623
>     time, seconds	9.75		9.84
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

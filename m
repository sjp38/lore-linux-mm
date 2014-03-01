Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id EDF486B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 19:35:58 -0500 (EST)
Received: by mail-ve0-f172.google.com with SMTP id jx11so1545402veb.3
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 16:35:58 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id fi2si1244042vdb.62.2014.02.28.16.35.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 16:35:57 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id id10so1500875vcb.13
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 16:35:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393625931-2858-1-git-send-email-quning@google.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
From: Ning Qu <quning@gmail.com>
Date: Fri, 28 Feb 2014 16:35:16 -0800
Message-ID: <CACQD4-5U3P+QiuNKzt5+VdDDi0ocphR+Jh81eHqG6_+KeaHyRw@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Sorry about my fault about the experiments, here is the real one.

Btw, apparently, there are still some questions about the results and
I will sync with Kirill about his test command line.

Below is just some simple experiment numbers from this patch, let me know if
you would like more:

Tested on Xeon machine with 64GiB of RAM, using the current default fault
order 4.

Sequential access 8GiB file
                        Baseline        with-patch
1 thread
    minor fault         8,389,052    4,456,530
    time, seconds    9.55            8.31

Random access 8GiB file
                        Baseline        with-patch
1 thread
    minor fault         8,389,315   6,423,386
    time, seconds    11.68         10.51



Best wishes,
-- 
Ning Qu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

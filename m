Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CB506B0098
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 15:27:24 -0500 (EST)
Date: Tue, 2 Feb 2010 21:27:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202202716.GS4135@random.random>
References: <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
 <20100202173158.GO6616@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202173158.GO6616@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 11:31:58AM -0600, Robin Holt wrote:
> Not better.  Still need to grab the mmap_sem.  How about this?

I don't think you need to grab mmap_sem, previous patch was ok if we
agree with the tradeoff that you still can't schedule in
->invalidate_page and it's unclear why that is ok. After you apply
transparent hugepage support, it'll break and I'll have to deal with
it somehow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

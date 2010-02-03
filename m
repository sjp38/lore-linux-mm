Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D71AF6B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:18:14 -0500 (EST)
Date: Wed, 3 Feb 2010 18:18:05 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100203171805.GC5959@random.random>
References: <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
 <20100202201718.GQ4135@random.random>
 <20100203004833.GS6653@sgi.com>
 <20100203171413.GB5959@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203171413.GB5959@random.random>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03, 2010 at 06:14:13PM +0100, Andrea Arcangeli wrote:
> generating mm corruption in fork and in ksm... the set_pte_at_notify

with fork I meant later during the do_wp_page... to avoid
confusion. (very fork is ok as it can schedule so you won't have to
defer the invalidate)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

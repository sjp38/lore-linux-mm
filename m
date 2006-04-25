Message-ID: <444E1406.7010101@yahoo.com.au>
Date: Tue, 25 Apr 2006 22:20:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/8] Page host virtual assist: unused / free pages.
References: <20060424123423.GB15817@skybase>
In-Reply-To: <20060424123423.GB15817@skybase>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com
List-ID: <linux-mm.kvack.org>

Himanshu Raj wrote:
> [patch 1/8] Page host virtual assist: unused / free pages.
> 
> A very simple but already quite effective improvement in the handling
> of guest memory vs. host memory is to tell the host when pages are
> free. That allows the host to avoid the paging of guest pages without
> meaningful content. The host can "forget" the page content and provide
> a fresh frame containing zeroes instead.
> 
> To communicate the two page states "unused" and "stable" to the host
> two architecture defined primitives page_hva_set_unused() and
> page_hva_set_stable() are introduced, which are used in the page
> allocator.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

This seems reasonable to me. But again, there is no reason for the
mm to know about this "hva" thing.

We already have arch_free_page. Can't you introduce an arch_alloc_page
and use those?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 29 Apr 2005 22:02:40 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] Page Fault Scalability V20: Avoid lock for anonymous write fault
Message-ID: <20050429210240.GA14774@infradead.org>
References: <20050429195901.15694.28520.sendpatchset@schroedinger.engr.sgi.com> <20050429195917.15694.21053.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050429195917.15694.21053.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 29, 2005 at 12:59:17PM -0700, Christoph Lameter wrote:
> Do not use the page_table_lock in do_anonymous_page. This will significantly
> increase the parallelism in the page fault handler for SMP systems. The patch
> also modifies the definitions of _mm_counter functions so that rss and anon_rss
> become atomic (and will use atomic64_t if available).

I thought we said all architectures should provide an atomic64_t (and
given that it's not actually 64bit on 32bit architecture we should
probably rename it to atomic_long_t)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

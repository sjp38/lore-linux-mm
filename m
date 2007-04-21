Date: Fri, 20 Apr 2007 23:51:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab allocators: Remove multiple alignment specifications.
Message-Id: <20070420235104.38c5ac82.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704202338100.11938@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
	<20070420223727.7b201984.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
	<20070420231129.9252ca67.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0704202338100.11938@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 23:38:43 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Cannot get around the readahead problems:
> 
>  CC      mm/truncate.o
> mm/readahead.c: In function 'page_cache_readahead':
> mm/readahead.c:586: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c:587: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c: In function 'try_context_based_readahead':
> mm/readahead.c:1414: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c: In function 'try_backward_prefetching':
> mm/readahead.c:1534: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c: In function 'page_cache_readahead_adaptive':
> mm/readahead.c:1687: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c:1693: error: 'struct file_ra_state' has no member named 
> 'prev_page'
> mm/readahead.c:1738: error: 'struct file_ra_state' has no member named 
> 'prev_page'

prev_page got renamed to prev_index.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

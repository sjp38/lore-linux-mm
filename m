Date: Fri, 20 Apr 2007 23:38:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: slab allocators: Remove multiple alignment specifications.
In-Reply-To: <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704202338100.11938@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
 <20070420223727.7b201984.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
 <20070420231129.9252ca67.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Cannot get around the readahead problems:

 CC      mm/truncate.o
mm/readahead.c: In function 'page_cache_readahead':
mm/readahead.c:586: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c:587: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c: In function 'try_context_based_readahead':
mm/readahead.c:1414: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c: In function 'try_backward_prefetching':
mm/readahead.c:1534: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c: In function 'page_cache_readahead_adaptive':
mm/readahead.c:1687: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c:1693: error: 'struct file_ra_state' has no member named 
'prev_page'
mm/readahead.c:1738: error: 'struct file_ra_state' has no member named 
'prev_page'
make[3]: *** [mm/readahead.o] Error 1
make[3]: *** Waiting for unfinished jobs....
make[2]: *** [mm] Error 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

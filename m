Message-ID: <44997596.7050903@google.com>
Date: Wed, 21 Jun 2006 09:36:38 -0700
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/14] Zoned VM counters V5
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> The patchset introduces a framework for counters that is a cross between the
> existing page_stats --which are simply global counters split per cpu-- and
> the approach of deferred incremental updates implemented for nr_pagecache.
> 
> Small per cpu 8 bit counters are added to struct zone. If the counter
> exceeds certain thresholds then the counters are accumulated in an array of
> atomic_long in the zone and in a global array that sums up all
> zone values. The small 8 bit counters are next to the per cpu page pointers
> and so they will be in high in the cpu cache when pages are allocated and
> freed.
> 
> Access to VM counter information for a zone and for the whole machine
> is then possible by simply indexing an array (Thanks to Nick Piggin for
> pointing out that approach). The access to the total number of pages of
> various types does no longer require the summing up of all per cpu counters.

Having the per-cpu counters with a global overflow seems like a really
nice way to do counters to me - is it worth doing this as a more
generalized counter type so that others could use it?


OTOH, I'm unsure why we're only using 8 bits in struct zone, which isn't
size critical. Is it just so you can pack vast numbers of different 
stats into a single cacheline?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

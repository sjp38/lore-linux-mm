Date: Wed, 9 May 2007 12:21:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/4] Use SLAB_ACCOUNT_RECLAIM to determine when
 __GFP_RECLAIMABLE should be used
In-Reply-To: <20070509082908.19219.63588.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705091219340.29526@schroedinger.engr.sgi.com>
References: <20070509082748.19219.48015.sendpatchset@skynet.skynet.ie>
 <20070509082908.19219.63588.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Mel Gorman wrote:

> Credit goes to Christoph Lameter for identifying this problem during review
> and suggesting this fix.

It was not a problem. It is just much simpler to use the existing 
information. Does not affect the correctness of what you are doing.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

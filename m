Message-ID: <47B4A0F7.50903@cs.helsinki.fi>
Date: Thu, 14 Feb 2008 22:13:43 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com> <20080214140614.GE17641@csn.ul.ie> <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com> <47B49520.4070201@cs.helsinki.fi> <Pine.LNX.4.64.0802141128430.375@schroedinger.engr.sgi.com> <47B49ADD.9010001@cs.helsinki.fi> <Pine.LNX.4.64.0802141153300.809@schroedinger.engr.sgi.com> <47B49E62.6020808@cs.helsinki.fi> <Pine.LNX.4.64.0802141207230.1041@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802141207230.1041@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> I would like to merge this patch into 2.6.25 and keep the other for mm to 
> maybe merge in 2.6.26. Not sure how safe the general use of the fallback 
> is. Definitely no problem for the kmalloc array.

Works for me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 21 May 2008 17:01:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <20080521234347.GA32707@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0805211701320.18793@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>
 <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
 <20080521234347.GA32707@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, David Howells <dhowells@redhat.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 May 2008, Paul Mundt wrote:

> It seems to, but I wonder if compound_order() needs to take a
> virt_to_head_page(objp) instead of virt_to_page()?

compound_order must be run on the head. So yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

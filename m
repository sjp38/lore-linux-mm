Date: Fri, 29 Feb 2008 11:34:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 08/10] slub: Remove BUG_ON() from ksize and omit checks
 for !SLUB_DEBUG
In-Reply-To: <47C7B826.4090603@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802291133060.11084@schroedinger.engr.sgi.com>
References: <20080229043401.900481416@sgi.com> <20080229043553.076119937@sgi.com>
 <47C7B826.4090603@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:

> Why are you wrapping the SLAB_DESTORY_BY_RCU case with CONFIG_SLUB_DEBUG too?

Mistake on my part. Corrected patch follows:

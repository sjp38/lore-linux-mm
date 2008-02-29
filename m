Date: Fri, 29 Feb 2008 11:31:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] slub: Rearrange #ifdef CONFIG_SLUB_DEBUG in
 calculate_sizes()
In-Reply-To: <47C7B463.8050208@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802291130330.11084@schroedinger.engr.sgi.com>
References: <20080229043401.900481416@sgi.com> <20080229043553.284904576@sgi.com>
 <47C7B463.8050208@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > Group SLUB_DEBUG code together to reduce the number of #ifdefs.
> > 
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> This doesn't just rearrange #ifdefs, it moves the poisoning checks under
> #ifdef too (which is safe). You might want to mention that in the changelogs.

Ok. Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

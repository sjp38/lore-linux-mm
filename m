Date: Wed, 29 Nov 2006 11:27:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <1164790207.32474.24.camel@taijtu>
Message-ID: <Pine.LNX.4.64.0611291125210.16189@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <1164790207.32474.24.camel@taijtu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Peter Zijlstra wrote:

> - this will skip the .pc directory where quilt resides, so you could do
> multiple iterations of this script.

find * ... does the same.

> - does in-place replacement with sed

Well I wanted to make sure that the original source is not corrupted if 
sed failes for some reason.
 
> - doesn't do the find in back-ticks which can cause it to run out of env
> space.

Good point. Is there some sort of library of helpful kernel scripts that 
you could contribute to?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

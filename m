Date: Fri, 18 Aug 2006 23:29:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Extract the allocpercpu functions from the slab
 allocator
Message-Id: <20060818232905.8fdacad4.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Aug 2006 21:14:06 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> The allocpercpu functions __alloc_percpu and __free_percpu() are heavily 
> using the slab allocator.

These functions don't exist since cpu-hotplug-compatible-alloc_percpu.patch.

Can you please see whether this cleanup is applicable to -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

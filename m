Date: Fri, 13 May 2005 04:37:49 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: NUMA aware slab allocator V2
In-Reply-To: <20050513043311.7961e694.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0505130436380.4500@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <20050512000444.641f44a9.akpm@osdl.org> <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
 <20050513000648.7d341710.akpm@osdl.org> <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
 <20050513043311.7961e694.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 13 May 2005, Andrew Morton wrote:

> > The definition for the number of NUMA nodes is dependent on
> > CONFIG_FLATMEM instead of CONFIG_NUMA in mm.
> > CONFIG_FLATMEM is not set on ppc64 because CONFIG_DISCONTIG is set! And
> > consequently nodes exist in a non NUMA config.
>
> I was testing 2.6.12-rc4 base.

There we still have the notion of nodes depending on CONFIG_DISCONTIG and
not on CONFIG_NUMA. The node stuff needs to be

#ifdef CONFIG_FLATMEM

or

#ifdef CONFIG_DISCONTIG

??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 16 Jan 2008 10:07:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
 large count NR_CPUs
In-Reply-To: <200801161834.39746.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0801161006000.9061@schroedinger.engr.sgi.com>
References: <20080113183453.973425000@sgi.com> <20080114101133.GA23238@elte.hu>
 <200801141230.56403.ak@suse.de> <200801161834.39746.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008, Nick Piggin wrote:

> Oh, just while I remember it also, something funny is that MAX_NUMNODES
> can be bigger than NR_CPUS on x86. I guess one can have CPUless nodes,
> but wouldn't it make sense to have an upper bound of NR_CPUS by default?

There are special configurations that some customers want which involves 
huge amounts of memory and just a few processors. In that case the number 
of nodes becomes larger than the number of processors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

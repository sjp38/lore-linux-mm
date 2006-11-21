Date: Tue, 21 Nov 2006 11:32:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: build error: sparsemem + SLOB
In-Reply-To: <20061121191410.GL4797@waste.org>
Message-ID: <Pine.LNX.4.64.0611211130440.30133@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com>
 <20061120183632.GD4797@waste.org> <20061121143253.51B5.Y-GOTO@jp.fujitsu.com>
 <20061121191410.GL4797@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006, Matt Mackall wrote:

> Are there any implications for preemptible kernels here?

Matt: Would  you mind if I replace SLOB with my new slab design? It is as 
memory efficient as yours (maybe even more since we do not have the 
header for each allocation). It can work efficiently in an SMP system 
(NUMA still under test). The code is more complex though. 
Still needs to mature.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

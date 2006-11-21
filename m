Date: Tue, 21 Nov 2006 19:54:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: build error: sparsemem + SLOB
In-Reply-To: <20061121191410.GL4797@waste.org>
Message-ID: <Pine.LNX.4.64.0611211951090.24360@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com>
 <20061120183632.GD4797@waste.org> <20061121143253.51B5.Y-GOTO@jp.fujitsu.com>
 <20061121191410.GL4797@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006, Matt Mackall wrote:
> 
> Are there any implications for preemptible kernels here?

I believe not: because that code which relies upon SLAB_DESTROY_BY_RCU's
guarantee already has to use rcu_read_lock(), which disables preemption.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

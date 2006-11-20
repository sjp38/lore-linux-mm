Date: Mon, 20 Nov 2006 13:22:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: build error: sparsemem + SLOB
In-Reply-To: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0611201321410.21552@schroedinger.engr.sgi.com>
References: <20061119210545.9708e366.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0611200855280.16845@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, mpm@selenic.com, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Nov 2006, Hugh Dickins wrote:

> Lucky so far.  Well, we'd actually have to be quite unlucky to ever
> see what page_lock_anon_vma/SLAB_DESTROY_BY_RCU are guarding against.

Hmmm... I had to repeatedly fix my new slab code when I broke 
DESTROY_BY_RCU. The machine wont even boot if that is not done right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

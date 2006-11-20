Message-ID: <4561E0FA.4040508@oracle.com>
Date: Mon, 20 Nov 2006 09:08:10 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: build error: sparsemem + SLOB
References: <20061119210545.9708e366.randy.dunlap@oracle.com> <Pine.LNX.4.64.0611200855280.16845@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611200855280.16845@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mpm@selenic.com, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 19 Nov 2006, Randy Dunlap wrote:
> 
>> mm/sparse.c: line 35 uses slab_is_available() but SLAB=n, SLOB=y.
> 
> I wonder if its worth bothering about SLOB?

It's OK with me to make some combination of SLOB and SPARSEMEM
an invalid config, as long as that is implemented in Kconfig.

> As far as I can tell SLOB is fundamentally racy since it does not support 
> SLAB_DESTROY_BY_RCU correctly. F.e. The constructor for the anon_vma will 
> be called on alloc without regard for RCU, we free an item and reuse it 
> without regard to RCU. This can potentially mess up the anon_vma locking 
> state while we access it.
> 
> Is SLOB used at all or have we been lucky so far?


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

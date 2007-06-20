Date: Wed, 20 Jun 2007 09:53:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/10] Memoryless nodes: SLUB support
In-Reply-To: <1182348612.5058.3.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706200951300.22446@schroedinger.engr.sgi.com>
References: <20070618191956.411091458@sgi.com>  <20070618192545.764710140@sgi.com>
 <1182348612.5058.3.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jun 2007, Lee Schermerhorn wrote:

> This patch didn't apply to 22-rc4-mm2.  Does it assume some other SLUB
> patches?

Yes sorry this was based on SLUB with patches already accepted by Andrew 
for SLUB.
 
> I resolved the conflicts by just doing what the description says:
> replacing all 'for_each_online_node" with "for_each_memory_node", but I
> was surprised that this one patch out of 10 didn't apply.  I'm probably
> missing some other patch.

I think you should be fine with that approach. There is a later patch that 
does more for_each_memory stuff for the policy layer. I'd appreciate it if 
you could check if that proposed change in semantics for memoryless 
nodes makes sense to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

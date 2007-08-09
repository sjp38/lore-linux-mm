Date: Thu, 9 Aug 2007 12:27:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 17/23] mm: count writeback pages per BDI
In-Reply-To: <1186687416.11797.182.camel@lappy>
Message-ID: <Pine.LNX.4.64.0708091225470.28074@schroedinger.engr.sgi.com>
References: <20070803123712.987126000@chello.nl>  <20070803125237.072937000@chello.nl>
  <Pine.LNX.4.64.0708091214330.27092@schroedinger.engr.sgi.com>
 <1186687416.11797.182.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Peter Zijlstra wrote:

> Less conditionals. We already have a branch for mapping, why create
> another?

Ah. Okay. This also avoids an interrupt enable disable since you can use 
__ functions. Hmmm... Would be good if we could move the vmstat 
NR_WRITEBACK update there too. Can a page without a mapping be under 
writeback? (Direct I/O?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

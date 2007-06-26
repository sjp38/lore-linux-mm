Date: Tue, 26 Jun 2007 01:18:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 15/26] Slab defrag: Support generic defragmentation for
 inode slab caches
Message-Id: <20070626011836.f4abb4ff.akpm@linux-foundation.org>
In-Reply-To: <20070618095917.005535114@sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095917.005535114@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 02:58:53 -0700 clameter@sgi.com wrote:

> This implements the ability to remove inodes in a particular slab
> from inode cache. In order to remove an inode we may have to write out
> the pages of an inode, the inode itself and remove the dentries referring
> to the node.
> 
> Provide generic functionality that can be used by filesystems that have
> their own inode caches to also tie into the defragmentation functions
> that are made available here.

Yes, this is tricky stuff.  I have vague ancestral memories that the sort
of inode work which you refer to here can cause various deadlocks, lockdep
warnings and such nasties when if we attempt to call it from the wrong
context (ie: from within fs code).

Possibly we could prevent that by skipping all this code if the caller
didn't have __GFP_FS.


I trust all the code in kick_inodes() was carefuly copied from
prue_icache() and such places - I didn't check it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

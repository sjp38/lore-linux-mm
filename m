Date: Tue, 26 Jun 2007 11:21:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 15/26] Slab defrag: Support generic defragmentation for
 inode slab caches
In-Reply-To: <20070626011836.f4abb4ff.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261119420.18010@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095917.005535114@sgi.com>
 <20070626011836.f4abb4ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> > Provide generic functionality that can be used by filesystems that have
> > their own inode caches to also tie into the defragmentation functions
> > that are made available here.
> 
> Yes, this is tricky stuff.  I have vague ancestral memories that the sort
> of inode work which you refer to here can cause various deadlocks, lockdep
> warnings and such nasties when if we attempt to call it from the wrong
> context (ie: from within fs code).

Right that is likelyi the reason why Michael did his stress test...
 
> Possibly we could prevent that by skipping all this code if the caller
> didn't have __GFP_FS.

We do. Look at the earlier patch.

> I trust all the code in kick_inodes() was carefuly copied from 
> prue_icache() and such places - I didn't check it.

Yup tried to remain faithful to that. We could increase the usefulness if 
I could take more liberties with the code in order to actually move an 
item instead of simply reclaiming. But its better to first have a proven 
correct solution before doing more work on that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

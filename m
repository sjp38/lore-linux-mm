Date: Tue, 26 Jun 2007 11:23:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 21/26] Slab defragmentation: support dentry defragmentation
In-Reply-To: <20070626011845.bfd4efe0.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261122130.18010@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095918.404020641@sgi.com>
 <20070626011845.bfd4efe0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> > +			 * objects.
> > +			 */
> > +			abort = 1;
> 
> It's unobvious why the entire shrink effort is abandoned if one busy dentry
> is encountered.  Please flesh the comment out explaining this.

If one item is busy then we cannot reclaim the slab. So what would be the 
use of continuing efforts. I thought I put that into the description? I 
can put that into the code too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

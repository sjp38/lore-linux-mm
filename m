Date: Wed, 24 Oct 2007 19:34:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 13/14] dentries: Extract common code to remove dentry
 from lru
Message-Id: <20071024193458.ca4300be.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0710241921570.29434@schroedinger.engr.sgi.com>
References: <20070925232543.036615409@sgi.com>
	<20070925233008.523093726@sgi.com>
	<20071022142939.1b815680.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0710241921570.29434@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Oct 2007 19:23:36 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 22 Oct 2007, Andrew Morton wrote:
> 
> > Doesn't seem like a terribly good change to me - it's one of those
> > cant-measure-a-difference changes which add up to a slower kernel after
> > we've merged three years worth of them.
> > 
> > Perhaps not all of those list_del_init() callers actually need to be using
> > the _init version?
> 
> Sometimes we check the list head using list_empty() so we cannot avoid 
> list_del_init. Always using list_del_init results in a consistent state of 
> affairs before the object is freed (which the slab defrag patchset depends 
> on)

OK, but it's slower.

So I think it should be changlogged as such, with an explanation that there
will (hopefully) be a net benefit because it enables slab defrag, and it
should be moved into the slab-defrag patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

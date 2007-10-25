Date: Wed, 24 Oct 2007 19:23:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 13/14] dentries: Extract common code to remove dentry
 from lru
In-Reply-To: <20071022142939.1b815680.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710241921570.29434@schroedinger.engr.sgi.com>
References: <20070925232543.036615409@sgi.com> <20070925233008.523093726@sgi.com>
 <20071022142939.1b815680.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Oct 2007, Andrew Morton wrote:

> Doesn't seem like a terribly good change to me - it's one of those
> cant-measure-a-difference changes which add up to a slower kernel after
> we've merged three years worth of them.
> 
> Perhaps not all of those list_del_init() callers actually need to be using
> the _init version?

Sometimes we check the list head using list_empty() so we cannot avoid 
list_del_init. Always using list_del_init results in a consistent state of 
affairs before the object is freed (which the slab defrag patchset depends 
on)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

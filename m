Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 06F416B0005
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:23:08 -0500 (EST)
Date: Tue, 5 Feb 2013 13:23:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: shmem: use new radix tree iterator
Message-ID: <20130205182301.GD993@cmpxchg.org>
References: <1359699238-7327-1-git-send-email-hannes@cmpxchg.org>
 <510CCD88.30200@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510CCD88.30200@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 02, 2013 at 12:25:44PM +0400, Konstantin Khlebnikov wrote:
> Johannes Weiner wrote:
> >In shmem_find_get_pages_and_swap, use the faster radix tree iterator
> >construct from 78c1d78 "radix-tree: introduce bit-optimized iterator".
> >
> >Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> 
> Hmm, ACK. shmem_unuse_inode() also can be redone in this way.
> I did something similar year ago: https://lkml.org/lkml/2012/2/10/388
> As result we can rid of radix_tree_locate_item() and shmem_find_get_pages_and_swap()

I remember your patches and am working on a totally unrelated series
that also gets rid of shmem_find_get_pages_and_swap().  Either way,
this thing's going down, so just I didn't bother with the conversion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

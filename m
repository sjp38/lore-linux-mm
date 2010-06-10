Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7EB5E6B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 08:43:04 -0400 (EDT)
Date: Thu, 10 Jun 2010 14:42:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100610124231.GE10827@quack.suse.cz>
References: <1275676854-15461-1-git-send-email-jack@suse.cz>
 <1275676854-15461-3-git-send-email-jack@suse.cz>
 <20100609164533.9d5c34dd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100609164533.9d5c34dd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@kernel.org, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 09-06-10 16:45:33, Andrew Morton wrote:
> On Fri,  4 Jun 2010 20:40:54 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > -#define RADIX_TREE_MAX_TAGS 2
> > +#define RADIX_TREE_MAX_TAGS 3
> 
> Adds another eight bytes to the radix_tree_node, I think.  What effect
> does this have upon the radix_tree_node_cachep packing for sl[aeiou]b? 
> Please add to changelog if you can work it out ;).
  The sizes of structure are:
32-bit: 288 vs 296
64-bit: 552 vs 560
  I have now checked (running different kernels because I wasn't sure the
computations I do are right) and that gives 7 objects per page with SLAB
and SLUB on a 64-bit kernel. I'll try to get also SLOB numbers for 64-bit
and possibly numbers for 32-bit archs (although it gets a bit tiring to try
all the kernels ;).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

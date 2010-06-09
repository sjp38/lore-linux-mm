Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEF76B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 19:46:07 -0400 (EDT)
Date: Wed, 9 Jun 2010 16:45:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-Id: <20100609164533.9d5c34dd.akpm@linux-foundation.org>
In-Reply-To: <1275676854-15461-3-git-send-email-jack@suse.cz>
References: <1275676854-15461-1-git-send-email-jack@suse.cz>
	<1275676854-15461-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@kernel.org, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  4 Jun 2010 20:40:54 +0200
Jan Kara <jack@suse.cz> wrote:

> -#define RADIX_TREE_MAX_TAGS 2
> +#define RADIX_TREE_MAX_TAGS 3

Adds another eight bytes to the radix_tree_node, I think.  What effect
does this have upon the radix_tree_node_cachep packing for sl[aeiou]b? 
Please add to changelog if you can work it out ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

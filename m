Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 96C956B01B5
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 18:18:59 -0400 (EDT)
Date: Fri, 18 Jun 2010 15:18:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] radix-tree: Implement function
 radix_tree_range_tag_if_tagged
Message-Id: <20100618151824.397a8a35.akpm@linux-foundation.org>
In-Reply-To: <1276706031-29421-2-git-send-email-jack@suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
	<1276706031-29421-2-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 18:33:50 +0200
Jan Kara <jack@suse.cz> wrote:

> Implement function for setting one tag if another tag is set
> for each item in given range.
> 

These two patches look OK to me.

fwiw I have a userspace test harness for radix-tree.c:
http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz.  Nick used it for a
while and updated it somewhat, but it's probably rather bitrotted and
surely needs to be taught how to test the post-2006 additions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

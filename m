Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF886B01CC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 08:09:39 -0400 (EDT)
Date: Mon, 21 Jun 2010 22:09:34 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] radix-tree: Implement function
 radix_tree_range_tag_if_tagged
Message-ID: <20100621120934.GB31679@laptop>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <1276706031-29421-2-git-send-email-jack@suse.cz>
 <20100618151824.397a8a35.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100618151824.397a8a35.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 03:18:24PM -0700, Andrew Morton wrote:
> On Wed, 16 Jun 2010 18:33:50 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > Implement function for setting one tag if another tag is set
> > for each item in given range.
> > 
> 
> These two patches look OK to me.
> 
> fwiw I have a userspace test harness for radix-tree.c:
> http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz.  Nick used it for a
> while and updated it somewhat, but it's probably rather bitrotted and
> surely needs to be taught how to test the post-2006 additions.
> 

Main thing I did was add RCU support (pretty dumb RCU but it found
a couple of bugs), and add some more tests. I'll try to find it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

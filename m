Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2BBEC6B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 09:42:54 -0400 (EDT)
Date: Wed, 23 Jun 2010 15:42:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] radix-tree: Implement function
 radix_tree_range_tag_if_tagged
Message-ID: <20100623134228.GD13649@quack.suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <1276706031-29421-2-git-send-email-jack@suse.cz>
 <20100618151824.397a8a35.akpm@linux-foundation.org>
 <20100621120934.GB31679@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621120934.GB31679@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 21-06-10 22:09:34, Nick Piggin wrote:
> On Fri, Jun 18, 2010 at 03:18:24PM -0700, Andrew Morton wrote:
> > On Wed, 16 Jun 2010 18:33:50 +0200
> > Jan Kara <jack@suse.cz> wrote:
> > 
> > > Implement function for setting one tag if another tag is set
> > > for each item in given range.
> > > 
> > 
> > These two patches look OK to me.
> > 
> > fwiw I have a userspace test harness for radix-tree.c:
> > http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz.  Nick used it for a
> > while and updated it somewhat, but it's probably rather bitrotted and
> > surely needs to be taught how to test the post-2006 additions.
> > 
> 
> Main thing I did was add RCU support (pretty dumb RCU but it found
> a couple of bugs), and add some more tests. I'll try to find it...
  Nick, any luck with finding updated tests?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

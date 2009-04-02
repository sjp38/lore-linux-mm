Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 285EB6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 05:00:14 -0400 (EDT)
Date: Thu, 2 Apr 2009 11:00:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: close page_mkwrite races
Message-ID: <20090402090009.GA22256@wotan.suse.de>
References: <20090330135307.GP31000@wotan.suse.de> <20090330135613.GQ31000@wotan.suse.de> <Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net> <20090401160241.ec2f4573.akpm@linux-foundation.org> <1238628811.18376.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238628811.18376.4.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 01, 2009 at 07:33:31PM -0400, Trond Myklebust wrote:
> On Wed, 2009-04-01 at 16:02 -0700, Andrew Morton wrote:
> > What is "the problem"?  Can we get "the problem"'s description included
> > in the changelog?
> > 
> > The patch is fairly ugly, somewhat costly and makes things (even) more
> > complex.    Sigh.
> 
> The problem is that currently, pages can be marked as dirty after they
> have been written out, or even during writeout.
> 
> IOW: the filesystem and the mm no longer agree on the state of the page,
> which again triggers issues such as
>   http://bugzilla.kernel.org/show_bug.cgi?id=12913

Thanks, that would go nicely at the top of the changelog.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

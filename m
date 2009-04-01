Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5266B0047
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 19:33:14 -0400 (EDT)
Subject: Re: [patch] mm: close page_mkwrite races
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20090401160241.ec2f4573.akpm@linux-foundation.org>
References: <20090330135307.GP31000@wotan.suse.de>
	 <20090330135613.GQ31000@wotan.suse.de>
	 <Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net>
	 <20090401160241.ec2f4573.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 01 Apr 2009 19:33:31 -0400
Message-Id: <1238628811.18376.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sage Weil <sage@newdream.net>, npiggin@suse.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-01 at 16:02 -0700, Andrew Morton wrote:
> What is "the problem"?  Can we get "the problem"'s description included
> in the changelog?
> 
> The patch is fairly ugly, somewhat costly and makes things (even) more
> complex.    Sigh.

The problem is that currently, pages can be marked as dirty after they
have been written out, or even during writeout.

IOW: the filesystem and the mm no longer agree on the state of the page,
which again triggers issues such as
  http://bugzilla.kernel.org/show_bug.cgi?id=12913

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

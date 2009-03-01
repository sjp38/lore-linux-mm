Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28F8F6B00A9
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 08:51:01 -0500 (EST)
Date: Sun, 1 Mar 2009 14:50:57 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090301135057.GA26905@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090301081744.GI26138@disturbed>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 01, 2009 at 07:17:44PM +1100, Dave Chinner wrote:
> On Wed, Feb 25, 2009 at 10:36:29AM +0100, Nick Piggin wrote:
> > I need this in fsblock because I am working to ensure filesystem metadata
> > can be correctly allocated and refcounted. This means that page cleaning
> > should not require memory allocation (to be really robust).
> 
> Which, unfortunately, is just a dream for any filesystem that uses
> delayed allocation. i.e. they have to walk the free space trees
> which may need to be read from disk and therefore require memory
> to succeed....

Well it's a dream because probably none of them get it right, but
that doesn't mean its impossible.

You don't need complete memory allocation up-front to be robust,
but having reserves or degraded modes that simply guarantee
forward progress is enough.

For example, if you need to read/write filesystem metadata to find
and allocate free space, then you really only need a page to do all
the IO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

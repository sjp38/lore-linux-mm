Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 11B616B00E1
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 04:43:39 -0500 (EST)
Date: Wed, 25 Feb 2009 10:43:36 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] change writepage prototype, introduce new page cleaning APIs
Message-ID: <20090225094336.GE22785@wotan.suse.de>
References: <20090225084739.GC22785@wotan.suse.de> <9106c300902250140t33a22a25s6bf49e1b08736dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9106c300902250140t33a22a25s6bf49e1b08736dd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: yawei niu <yawei.niu@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 05:40:52PM +0800, yawei niu wrote:
> On Wed, Feb 25, 2009 at 4:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> 
> > Hi,
> >
> > I have a problem with writepage because the caller clears the page dirty
> > bit before calling the filesystem. I want to do proper refcounting on
> > filesystem metadata in fsblock, and this includes pinning the metadata
> > when it is dirty.
> Is it possible that two threads trigger writepage on same page in this way?

It shouldn't be, because the filesystem would have to hold page lock
over the operation and until it either clears dirty, or decides it is
not going to do the writeback. No different from the former rules in
that respect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

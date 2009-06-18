Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDCB6B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 08:00:55 -0400 (EDT)
Date: Thu, 18 Jun 2009 08:00:40 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH 07/11] vfs: Unmap underlying metadata of new data
	buffers only when buffer is mapped
Message-ID: <20090618120040.GB32164@mit.edu>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-8-git-send-email-jack@suse.cz> <20090617103543.GB29931@wotan.suse.de> <20090617120520.GD2612@duck.suse.cz> <20090617135331.GA20678@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617135331.GA20678@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 03:53:31PM +0200, Nick Piggin wrote:
> >   You're right it's not directly connected with the mkwrite problem and
> > can go in separately. Given how late it is, I'd like to get patch number 2
> > reviewed (generic mkwrite changes), so that it can go together with patch
> > number 4 (ext4 fixes) in the current merge window. The rest is not that
> > urgent since it's not oopsable and you can hit it only when running out
> > of space (or hitting quota limit)...
> 
> Sorry I was so late with looking at it. I am reading it now though
> (especially #2) ;)

Thanks, as I have additional ext4 patches which are queued up and
blocked behind these patches.  :-)

						 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

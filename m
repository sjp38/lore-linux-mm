Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 775836B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:37:06 -0400 (EDT)
Date: Tue, 22 Sep 2009 19:37:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/7] ext4: Convert filesystem to the new truncate
	calling convention
Message-ID: <20090922173704.GB31447@duck.suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz> <1253200907-31392-6-git-send-email-jack@suse.cz> <20090922143604.GA2183@ZenIV.linux.org.uk> <20090922171604.GA31447@duck.suse.cz> <20090922172347.GG14381@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090922172347.GG14381@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

On Tue 22-09-09 18:23:47, Al Viro wrote:
> On Tue, Sep 22, 2009 at 07:16:04PM +0200, Jan Kara wrote:
> > > No.  We already have one half-finished series here; mixing it with another
> > > one is not going to happen.  Such flags are tolerable only as bisectability
> > > helpers.  They *must* disappear by the end of series.  Before it can be
> > > submitted for merge.
> > > 
> > > In effect, you are mixing truncate switchover with your writepage one.
> > > Please, split and reorder.
> 
> >   Well, this wasn't meant as a final version of those patches. It was
> > meant as a request for comment whether it makes sence to fix the problem
> > how I propose to fix it. If we agree on that, I'll go and convert the rest
> > of filesystems so that we can remove .new_writepage hack. By that time I
> > hope that new truncate sequence patches will be merged so that dependency
> > should go away as well...
> 
> Could you carve just the ext4 part of truncate series out of that and
> post it separately?
  Definitely. Actually, I've sent that patch to Nick in private but you're
right I should have posted it to the list as well. Will do it in a moment.
Thanks for a reminder.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

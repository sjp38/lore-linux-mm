Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 91C336B00F2
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 20:04:40 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id e4so1389582wiv.16
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:04:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eo20si38767wid.38.2014.02.21.17.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 17:04:38 -0800 (PST)
Date: Sat, 22 Feb 2014 02:04:36 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Revert "writeback: do not sync data dirtied after sync
 start"
Message-ID: <20140222010436.GB21405@quack.suse.cz>
References: <1392978601-18002-1-git-send-email-jack@suse.cz>
 <20140221115742.04f893323ce6f9d693212787@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140221115742.04f893323ce6f9d693212787@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri 21-02-14 11:57:42, Andrew Morton wrote:
> On Fri, 21 Feb 2014 11:30:01 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > This reverts commit c4a391b53a72d2df4ee97f96f78c1d5971b47489. Dave
> > Chinner <david@fromorbit.com> has reported the commit may cause some
> > inodes to be left out from sync(2). This is because we can call
> > redirty_tail() for some inode (which sets i_dirtied_when to current time)
> > after sync(2) has started or similarly requeue_inode() can set
> > i_dirtied_when to current time if writeback had to skip some pages. The
> > real problem is in the functions clobbering i_dirtied_when but fixing
> > that isn't trivial so revert is a safer choice for now.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> No cc:stable?  The patch is applicable to 3.13.x.
  Ah, forgot about it. Thanks for the reminder!

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

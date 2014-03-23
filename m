Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 675F76B00A3
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 10:09:37 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so1710978wib.16
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 07:09:36 -0700 (PDT)
Date: Sun, 23 Mar 2014 15:02:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140323140244.GF2813@quack.suse.cz>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
 <20140321214410.GE23173@kvack.org>
 <20140321225437.GB9074@birch.djwong.org>
 <20140322002909.GT10561@lenny.home.zabbo.net>
 <20140322023216.GC9074@birch.djwong.org>
 <20140322094320.GD9074@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140322094320.GD9074@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Zach Brown <zab@redhat.com>, Benjamin LaHaise <bcrl@kvack.org>, axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Sat 22-03-14 02:43:20, Darrick J. Wong wrote:
> On Fri, Mar 21, 2014 at 07:32:16PM -0700, Darrick J. Wong wrote:
> > On Fri, Mar 21, 2014 at 05:29:09PM -0700, Zach Brown wrote:
> > > I'll admit, though, that I don't really like having to fetch the 'has'
> > > bits first to find out how large the rest of the struct is.  Maybe
> > > that's not worth worrying about.
> > 
> > I'm not worrying about having to pluck 'has' out of the structure, but needing
> > a function to tell me how big of a buffer I need for a given pile of flags
> > seems ... icky.  But maybe the ease of modifying strace and security auditors
> > would make it worth it?
> 
> How about explicitly specifying the structure size in struct some_more_args,
> and checking that against whatever we find in .has?  Hm.  I still think that's
> too clever for my brain to keep together for long.
> 
> I'm also nervous that we could be creating this monster of a structure wherein
> some user wants to tack the first and last hints ever created onto an IO, so
> now we have to lug this huge structure around that has space for hints that
> we're not going to use, and most of which is zeroes.
  Well, why does it matter that the structure would be big? Are do you
think the memory consumption would matter?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

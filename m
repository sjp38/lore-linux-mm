Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 13D8A6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 16:26:39 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so1976811wgh.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 13:26:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b44si7387133eez.98.2014.01.08.13.26.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 13:26:38 -0800 (PST)
Date: Wed, 8 Jan 2014 22:26:36 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
Message-ID: <20140108212636.GC15313@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
 <20140107122301.GC16640@quack.suse.cz>
 <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
 <20140108111640.GD8256@quack.suse.cz>
 <CAK25hWN_tWu=HrOzs-eu6UFbp-6G=3pZJs+svcBu0hBxErm02g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK25hWN_tWu=HrOzs-eu6UFbp-6G=3pZJs+svcBu0hBxErm02g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Wed 08-01-14 23:56:57, Saket Sinha wrote:
> >> One of the big problems was that too many copyups were made on the
> >> read-write file system. So we decided to implement an union file
> >> system designed for diskless systems, with the following
> >> functionalities:
> >>
> >> 1. union between only one read-only and one read-write file systems
> >>
> >> 2. if only the file metadata are modified, then do not
> >> copy the whole file on the read-write files system but
> >> only the metadata (stored with a file named as the file
> >> itself prefixed by '.me.')
> >   So do you do anything special at CERN so that metadata is often modified
> > without data being changed? Because there are only two operations where I
> > can imagine this to be useful:
> > 1) atime update - but you better turn atime off for unioned filesystem
> >    anyway.
> > 2) xattr update
> >
> As already mentioned that the issue that we were facing was that "too
> many copyups were made on the  read-write file system".
  But my question is: In which cases specifically do you want to avoid
copyups as compared to e.g. Overlayfs?

> Writes to a file system in a  unioning file system will produce many
> duplicated blocks in memory since it uses a stackable filesystem
> approach so response time for a particular operation is also a
> concern.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

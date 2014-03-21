Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7586B0151
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:40:08 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so2935373pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:40:07 -0700 (PDT)
Date: Fri, 21 Mar 2014 14:39:59 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140321213959.GC5437@birch.djwong.org>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <x49wqfny4ys.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49wqfny4ys.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 10:57:31AM -0400, Jeff Moyer wrote:
> "Darrick J. Wong" <darrick.wong@oracle.com> writes:
> 
> > This RFC provides a rough implementation of a mechanism to allow
> > userspace to attach protection information (e.g. T10 DIF) data to a
> > disk write and to receive the information alongside a disk read.  The
> > interface is an extension to the AIO interface: two new commands
> > (IOCB_CMD_P{READ,WRITE}VM) are provided.  The last struct iovec in the
> 
> Sorry for the shallow question, but what does that M stand for?

Hmmm... I really don't remember why I picked 'M'.  Probably because it implied
that the IO has extra 'M'etadata associated with it.

But now I see, 'VM' connotes something entirely wrong.

--D
> 
> Cheers,
> Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

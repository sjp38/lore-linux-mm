Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 93E0A6B00E5
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:14:21 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id c9so730303qcz.30
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:14:21 -0700 (PDT)
Date: Wed, 2 Apr 2014 12:14:18 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [RFC PATCH DONOTMERGE v2 0/6] userspace PI passthrough via
 AIO/DIO
Message-ID: <20140402191418.GH2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140324162231.10848.4863.stgit@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 24, 2014 at 09:22:31AM -0700, Darrick J. Wong wrote:
> This RFC provides a rough implementation of a mechanism to allow
> userspace to attach protection information (e.g. T10 DIF) data to a
> disk write and to receive the information alongside a disk read.

I have some comments for you! :)  Mostly about the interface up in aio.
I don't have all that much to say about the bio/pi bits.

> Patch #2 implements a generic IO extension interface so that we can
> receive a struct io_extension from userspace containing the structure
> size, a flag telling us which extensions we'd like to use (ie_has),
> and (eventually) extension data.  There's a small framework for
> mapping ie_has bits to actual extensions.

I still really don't think that we should be thinking of these as
generic extensions.  We're talking about arguments to syscalls.  's a
small number of them with strong semantics because they're a part of the
syscall ABI.  I don't think we should implement them by iterating over
per-field ops structs.

Anyway, more in reply to the patches.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

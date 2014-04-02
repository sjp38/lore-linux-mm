Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8E46B0104
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:05:26 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so674044qaj.21
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:05:26 -0700 (PDT)
Date: Wed, 2 Apr 2014 13:05:23 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [RFC PATCH DONOTMERGE v2 0/6] userspace PI passthrough via
 AIO/DIO
Message-ID: <20140402200523.GL2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140402191418.GH2394@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402191418.GH2394@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

> 's a small number of them with strong semantics because they're a part
> of the syscall ABI.

("There's" a small number of them..  vim troubles :))

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

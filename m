Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD486B012B
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 18:33:17 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so837707qaq.24
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 15:33:16 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:33:11 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH 3/6] aio/dio: enable PI passthrough
Message-ID: <20140402223311.GN2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162251.10848.56452.stgit@birch.djwong.org>
 <20140402200133.GK2394@lenny.home.zabbo.net>
 <20140402204420.GB10230@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402204420.GB10230@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

> One thing I'm not sure about: What's the largest IO (in terms of # of blocks,
> not # of struct iovecs) that I can throw at the kernel?

Yeah, dunno.  I'd guess big :).  I'd hope that the PI code already has a
way to clamp the size of bios if there's a limit to the size of PI data
that can be managed downstream?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

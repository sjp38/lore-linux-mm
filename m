Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2DCA6B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 19:45:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so19549830pfr.3
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 16:45:52 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i10si849380pgs.259.2017.10.24.16.45.45
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 16:45:46 -0700 (PDT)
Date: Wed, 25 Oct 2017 08:45:38 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 4/8] lockdep: Add a kernel parameter,
 crossrelease_fullstack
Message-ID: <20171024234538.GM3310@X58A-UD3R>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
 <1508837889-16932-5-git-send-email-byungchul.park@lge.com>
 <20171024100858.2rw7wnhtj7d3iyzk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024100858.2rw7wnhtj7d3iyzk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, axboe@kernel.dk, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

On Tue, Oct 24, 2017 at 12:08:58PM +0200, Ingo Molnar wrote:
> This is really unnecessarily complex.

I mis-understood your suggestion. I will change it.

> The proper logic is to introduce the crossrelease_fullstack boot parameter, and to 
> also have a Kconfig option that enables it: 
> 
> 	CONFIG_BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK=y
> 
> No #ifdefs please - just an "if ()" branch dependent on the current value of 
> crossrelease_fullstack.

Ok. I will.

Thanks,
Byungchul

> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

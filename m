Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id CB2906B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:22:09 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so5370351eek.27
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:22:09 -0800 (PST)
Received: from trent.utfs.org (trent.utfs.org. [2a03:3680:0:3::67])
        by mx.google.com with ESMTP id f45si7482919eep.194.2014.02.13.17.22.07
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:22:08 -0800 (PST)
Date: Thu, 13 Feb 2014 17:22:06 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: 3.14.0-rc2: WARNING: at mm/slub.c:1007
In-Reply-To: <20140214011453.GP13997@dastard>
Message-ID: <alpine.DEB.2.19.4.1402131721190.6233@trent.utfs.org>
References: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org> <20140213222602.GK13997@dastard> <alpine.DEB.2.19.4.1402131531290.6233@trent.utfs.org> <20140214011453.GP13997@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Fri, 14 Feb 2014 at 12:14, Dave Chinner wrote:
> > OK, so the "possible irq lock inversion dependency detected" is a lockdep 
> > regression, as you explained in the xfs-list thread. What about the 
> > "RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected" warning - I 
> > haven't seen it again though, only once with 3.14.0-rc2.
> 
> That was also an i_lock/mmapsem issue, so it's likely to be the same
> root cause. I'm testing a fix for it at the moment.

Understood. Thanks for looking into this.

Christian.
-- 
BOFH excuse #129:

The ring needs another token

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

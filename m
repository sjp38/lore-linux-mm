Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDA26B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:34:26 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so5357091eek.36
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:34:25 -0800 (PST)
Received: from trent.utfs.org (trent.utfs.org. [2a03:3680:0:3::67])
        by mx.google.com with ESMTP id x7si7093307eef.135.2014.02.13.15.34.24
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 15:34:24 -0800 (PST)
Date: Thu, 13 Feb 2014 15:34:19 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: 3.14.0-rc2: WARNING: at mm/slub.c:1007
In-Reply-To: <20140213222602.GK13997@dastard>
Message-ID: <alpine.DEB.2.19.4.1402131531290.6233@trent.utfs.org>
References: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org> <20140213222602.GK13997@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Fri, 14 Feb 2014 at 09:26, Dave Chinner wrote:
> > after upgrading from 3.13-rc8 to 3.14.0-rc2 on this PowerPC G4 machine, 
> > the WARNING below was printed.
> > 
> > Shortly after, a lockdep warning appeared (possibly related to my 
> > post to the XFS list yesterday[0]).
> 
> Unlikely.

OK, so the "possible irq lock inversion dependency detected" is a lockdep 
regression, as you explained in the xfs-list thread. What about the 
"RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected" warning - I 
haven't seen it again though, only once with 3.14.0-rc2.

Christian.
-- 
BOFH excuse #108:

The air conditioning water supply pipe ruptured over the machine room

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

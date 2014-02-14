Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8C32B6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:20:12 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so11544844pbc.22
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:20:12 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id xf4si3786960pab.220.2014.02.13.17.20.10
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:20:11 -0800 (PST)
Date: Fri, 14 Feb 2014 12:14:53 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 3.14.0-rc2: WARNING: at mm/slub.c:1007
Message-ID: <20140214011453.GP13997@dastard>
References: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org>
 <20140213222602.GK13997@dastard>
 <alpine.DEB.2.19.4.1402131531290.6233@trent.utfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.19.4.1402131531290.6233@trent.utfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Kujau <lists@nerdbynature.de>
Cc: LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Thu, Feb 13, 2014 at 03:34:19PM -0800, Christian Kujau wrote:
> On Fri, 14 Feb 2014 at 09:26, Dave Chinner wrote:
> > > after upgrading from 3.13-rc8 to 3.14.0-rc2 on this PowerPC G4 machine, 
> > > the WARNING below was printed.
> > > 
> > > Shortly after, a lockdep warning appeared (possibly related to my 
> > > post to the XFS list yesterday[0]).
> > 
> > Unlikely.
> 
> OK, so the "possible irq lock inversion dependency detected" is a lockdep 
> regression, as you explained in the xfs-list thread. What about the 
> "RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected" warning - I 
> haven't seen it again though, only once with 3.14.0-rc2.

That was also an i_lock/mmapsem issue, so it's likely to be the same
root cause. I'm testing a fix for it at the moment.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

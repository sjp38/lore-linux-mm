Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2B6B6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:31:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id g83so296749491oib.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:31:24 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id y2si7717968itc.49.2016.05.31.00.31.23
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 00:31:24 -0700 (PDT)
Date: Tue, 31 May 2016 17:31:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: shrink_active_list/try_to_release_page bug? (was Re: xfs trace
 in 4.4.2 / also in 4.3.3 WARNING fs/xfs/xfs_aops.c:1232 xfs_vm_releasepage)
Message-ID: <20160531073119.GD12670@dastard>
References: <20160516010602.GA24980@bfoster.bfoster>
 <57420A47.2000700@profihost.ag>
 <20160522213850.GE26977@dastard>
 <574BEA84.3010206@profihost.ag>
 <20160530223657.GP26977@dastard>
 <20160531010724.GA9616@bbox>
 <20160531025509.GA12670@dastard>
 <20160531035904.GA17371@bbox>
 <20160531060712.GC12670@dastard>
 <574D2B1E.2040002@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <574D2B1E.2040002@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Minchan Kim <minchan@kernel.org>, Brian Foster <bfoster@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 31, 2016 at 08:11:42AM +0200, Stefan Priebe - Profihost AG wrote:
> > I'm half tempted at this point to mostly ignore this mm/ behavour
> > because we are moving down the path of removing buffer heads from
> > XFS. That will require us to do different things in ->releasepage
> > and so just skipping dirty pages in the XFS code is the best thing
> > to do....
> 
> does this change anything i should test? Or is 4.6 still the way to go?

Doesn't matter now - the warning will still be there on 4.6. I think
you can simply ignore it as the XFS code appears to be handling the
dirty page that is being passed to it correctly. We'll work out what
needs to be done to get rid of the warning for this case, wether it
be a mm/ change or an XFS change.

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

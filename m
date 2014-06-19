Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4A06E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 22:03:57 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so1204482pbc.30
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 19:03:56 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id ur10si825593pac.190.2014.06.18.19.03.54
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 19:03:56 -0700 (PDT)
Date: Thu, 19 Jun 2014 12:03:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS WARN_ON in xfs_vm_writepage
Message-ID: <20140619020340.GI4453@dastard>
References: <20140613051631.GA9394@redhat.com>
 <20140613062645.GZ9508@dastard>
 <20140613141925.GA24199@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140613141925.GA24199@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, xfs@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jun 13, 2014 at 10:19:25AM -0400, Dave Jones wrote:
> On Fri, Jun 13, 2014 at 04:26:45PM +1000, Dave Chinner wrote:
> 
> > >  970         if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
> > >  971                         PF_MEMALLOC))
> >
> > What were you running at the time? The XFS warning is there to
> > indicate that memory reclaim is doing something it shouldn't (i.e.
> > dirty page writeback from direct reclaim), so this is one for the mm
> > folk to work out...
> 
> Trinity had driven the machine deeply into swap, and the oom killer was
> kicking in pretty often. Then this happened.

Yup, sounds like a problem somewhere in mm/vmscan.c....

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB9D6B00CA
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 10:19:41 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so3593895qac.39
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 07:19:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c18si4760718qaq.0.2014.06.13.07.19.40
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 07:19:40 -0700 (PDT)
Date: Fri, 13 Jun 2014 10:19:25 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: XFS WARN_ON in xfs_vm_writepage
Message-ID: <20140613141925.GA24199@redhat.com>
References: <20140613051631.GA9394@redhat.com>
 <20140613062645.GZ9508@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140613062645.GZ9508@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jun 13, 2014 at 04:26:45PM +1000, Dave Chinner wrote:

> >  970         if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
> >  971                         PF_MEMALLOC))
>
> What were you running at the time? The XFS warning is there to
> indicate that memory reclaim is doing something it shouldn't (i.e.
> dirty page writeback from direct reclaim), so this is one for the mm
> folk to work out...

Trinity had driven the machine deeply into swap, and the oom killer was
kicking in pretty often. Then this happened.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

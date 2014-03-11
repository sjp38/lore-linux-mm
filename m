Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA7F6B0092
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 09:20:28 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hr13so5656067lab.31
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:20:27 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id p7si21988457lae.68.2014.03.11.06.20.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 06:20:26 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id u14so5529718lbd.5
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:20:25 -0700 (PDT)
Date: Tue, 11 Mar 2014 17:20:24 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311132024.GC32390@moon>
References: <20140305174503.GA16335@redhat.com>
 <20140305175725.GB16335@redhat.com>
 <20140307002210.GA26603@redhat.com>
 <20140311024906.GA9191@redhat.com>
 <20140310201340.81994295.akpm@linux-foundation.org>
 <20140310214612.3b4de36a.akpm@linux-foundation.org>
 <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311053017.GB14329@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 01:30:17AM -0400, Dave Jones wrote:
>  > >  > 
>  > >  > I don't see any holes in regular migration.  Do you know if this is
>  > >  > reproducible with CONFIG_NUMA_BALANCING=n or CONFIG_NUMA=n?
>  > > 
>  > > CONFIG_NUMA_BALANCING was n already btw, so I'll do a NUMA=n run.
>  > 
>  > There probably isn't much point unless trinity is using
>  > sys_move_pages().  Is it?  If so it would be interesting to disable
>  > trinity's move_pages calls and see if it still fails.
> 
> Ok, with move_pages excluded it still oopses.

Dave, is it possible to somehow figure out was someone reading pagemap file
at moment of the bug triggering?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 059B16B00B5
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:39:28 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so21422958qgf.0
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:39:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y4si11608940qad.73.2014.03.11.10.39.28
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 10:39:28 -0700 (PDT)
Date: Tue, 11 Mar 2014 13:39:17 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311173917.GB4693@redhat.com>
References: <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
 <20140311134158.GD32390@moon>
 <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
 <20140311171045.GA4693@redhat.com>
 <20140311173603.GG32390@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311173603.GG32390@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 09:36:03PM +0400, Cyrill Gorcunov wrote:
 > On Tue, Mar 11, 2014 at 01:10:45PM -0400, Dave Jones wrote:
 > >  > 
 > >  > Dave, iirc trinity can write log file pointing which exactly syscall sequence
 > >  > was passed, right? Share it too please.
 > > 
 > > Hm, I may have been mistaken, and the damage was done by a previous run.
 > > I went from being able to reproduce it almost instantly to now not being able
 > > to reproduce it at all.  Will keep trying.
 > 
 > Sasha already gave a link to the syscalls sequence, so no rush.

It'd be nice to get a more concise reproducer, his list had a little of everything in there.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

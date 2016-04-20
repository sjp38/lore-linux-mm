Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 536A96B0261
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 04:10:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so74244870pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 01:10:31 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u184si4209166pfu.78.2016.04.20.01.10.29
        for <linux-mm@kvack.org>;
        Wed, 20 Apr 2016 01:10:30 -0700 (PDT)
Date: Wed, 20 Apr 2016 17:13:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: linux-next crash during very early boot
Message-ID: <20160420081345.GC7071@js1304-P5Q-DELUXE>
References: <3689.1460593786@turing-police.cc.vt.edu>
 <20160414013546.GA9198@js1304-P5Q-DELUXE>
 <58269.1460729433@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58269.1460729433@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 15, 2016 at 10:10:33AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 14 Apr 2016 10:35:47 +0900, Joonsoo Kim said:
> > On Wed, Apr 13, 2016 at 08:29:46PM -0400, Valdis Kletnieks wrote:
> > > I'm seeing my laptop crash/wedge up/something during very early
> > > boot - before it can write anything to the console.  Nothing in pstore,
> > > need to hold down the power button for 6 seconds and reboot.
> > >
> > > git bisect points at:
> > >
> > > commit 7a6bacb133752beacb76775797fd550417e9d3a2
> > > Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > Date:   Thu Apr 7 13:59:39 2016 +1000
> > >
> > >     mm/slab: factor out kmem_cache_node initialization code
> > >
> > >     It can be reused on other place, so factor out it.  Following patch wil
> l
> > >     use it.
> > >
> > >
> > > Not sure what the problem is - the logic *looks* ok at first read.  The
> > > patch *does* remove a spin_lock_irq() - but I find it difficult to
> > > believe that with it gone, my laptop is able to hit the race condition
> > > the spinlock protects against *every single boot*.
> > >
> > > The only other thing I see is that n->free_limit used to be assigned
> > > every time, and now it's only assigned at initial creation.
> >
> > Hello,
> >
> > My fault. It should be assgined every time. Please test below patch.
> > I will send it with proper SOB after you confirm the problem disappear.
> > Thanks for report and analysis!
> 
> Following up - I verified that it was your patch series and not a bad bisect
> by starting with a clean next-20160413 and reverting that series - and the
> resulting kernel boots fine.
> 
> Will take a closer look at your fix patch and figure out what's still changed
> afterwards - there's obviously some small semantic change that actually
> matters, but we're not spotting it yet...

Hello,

Do you try to test the patch in following link on top of my fix for "mm/slab:
factor out kmem_cache_node initialization code"?

https://lkml.org/lkml/2016/4/10/703

I mentioned it in another thread but you didn't reply it so I'm
curious.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

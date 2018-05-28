Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B14396B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 00:39:18 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c8-v6so9634752qth.21
        for <linux-mm@kvack.org>; Sun, 27 May 2018 21:39:18 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l18-v6si2680075qkk.277.2018.05.27.21.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 21:39:17 -0700 (PDT)
Message-ID: <1527482351.2693.12.camel@themaw.net>
Subject: Re: [PATCH] mm-kasan-dont-vfree-nonexistent-vm_area-fix
From: Ian Kent <raven@themaw.net>
Date: Mon, 28 May 2018 12:39:11 +0800
In-Reply-To: <1527480795.2693.4.camel@themaw.net>
References: <dabee6ab-3a7a-51cd-3b86-5468718e0390@virtuozzo.com>
	 <201805261122.HdUpobQm%fengguang.wu@intel.com>
	 <20180525204804.3a655370ef4b41e0d96e03f3@linux-foundation.org>
	 <1527480795.2693.4.camel@themaw.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On Mon, 2018-05-28 at 12:13 +0800, Ian Kent wrote:
> On Fri, 2018-05-25 at 20:48 -0700, Andrew Morton wrote:
> > On Sat, 26 May 2018 11:31:35 +0800 kbuild test robot <lkp@intel.com> wrote:
> > 
> > > Hi Andrey,
> > > 
> > > I love your patch! Yet something to improve:
> > > 
> > > [auto build test ERROR on mmotm/master]
> > > [cannot apply to v4.17-rc6]
> > > [if your patch is applied to the wrong git tree, please drop us a note to
> > > help improve the system]
> > > 
> > > url:    https://github.com/0day-ci/linux/commits/Andrey-Ryabinin/mm-kasan-
> > > do
> > > nt-vfree-nonexistent-vm_area-fix/20180526-093255
> > > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > > config: sparc-allyesconfig (attached as .config)
> > > compiler: sparc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > > reproduce:
> > >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin
> > > /m
> > > ake.cross -O ~/bin/make.cross
> > >         chmod +x ~/bin/make.cross
> > >         # save the attached .config to linux build tree
> > >         make.cross ARCH=sparc 
> > > 
> > > All errors (new ones prefixed by >>):
> > > 
> > >    fs/autofs/inode.o: In function `autofs_new_ino':
> > >    inode.c:(.text+0x220): multiple definition of `autofs_new_ino'
> > >    fs/autofs/inode.o:inode.c:(.text+0x220): first defined here
> > >    fs/autofs/inode.o: In function `autofs_clean_ino':
> > >    inode.c:(.text+0x280): multiple definition of `autofs_clean_ino'
> > >    fs/autofs/inode.o:inode.c:(.text+0x280): first defined here
> > 
> > There's bot breakage here - clearly that patch didn't cause this error.
> > 
> > Ian, this autofs glitch may still not be fixed.
> 
> Yes, autofs-make-autofs4-Kconfig-depend-on-AUTOFS_FS.patch should have
> fixed that.
> 
> I tied a bunch of .config combinations and I was unable to find any that
> lead to both CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS being defined.

Oh, autofs-make-autofs4-Kconfig-depend-on-AUTOFS_FS.patch was sent as
a follow up patch which means it's still possible to have both
CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS set between 
autofs-create-autofs-Kconfig-and-Makefile.patch and the above patch.

Perhaps all that's needed is to fold the follow up patch into
autofs-create-autofs-Kconfig-and-Makefile.patch to close that
possibility.

I'll check that can be done without problem.

> 
> I must be missing something else, I'll investigate.

And I'll check if there's anything else I'm missing.

Sorry for the inconvenience.

> 
> Ian

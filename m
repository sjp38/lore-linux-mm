Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF6E6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 00:13:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f188-v6so7522764wme.2
        for <linux-mm@kvack.org>; Sun, 27 May 2018 21:13:24 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id d18-v6si864959eds.170.2018.05.27.21.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 21:13:22 -0700 (PDT)
Message-ID: <1527480795.2693.4.camel@themaw.net>
Subject: Re: [PATCH] mm-kasan-dont-vfree-nonexistent-vm_area-fix
From: Ian Kent <raven@themaw.net>
Date: Mon, 28 May 2018 12:13:15 +0800
In-Reply-To: <20180525204804.3a655370ef4b41e0d96e03f3@linux-foundation.org>
References: <dabee6ab-3a7a-51cd-3b86-5468718e0390@virtuozzo.com>
	 <201805261122.HdUpobQm%fengguang.wu@intel.com>
	 <20180525204804.3a655370ef4b41e0d96e03f3@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On Fri, 2018-05-25 at 20:48 -0700, Andrew Morton wrote:
> On Sat, 26 May 2018 11:31:35 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > Hi Andrey,
> > 
> > I love your patch! Yet something to improve:
> > 
> > [auto build test ERROR on mmotm/master]
> > [cannot apply to v4.17-rc6]
> > [if your patch is applied to the wrong git tree, please drop us a note to
> > help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Andrey-Ryabinin/mm-kasan-do
> > nt-vfree-nonexistent-vm_area-fix/20180526-093255
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: sparc-allyesconfig (attached as .config)
> > compiler: sparc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/m
> > ake.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=sparc 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    fs/autofs/inode.o: In function `autofs_new_ino':
> >    inode.c:(.text+0x220): multiple definition of `autofs_new_ino'
> >    fs/autofs/inode.o:inode.c:(.text+0x220): first defined here
> >    fs/autofs/inode.o: In function `autofs_clean_ino':
> >    inode.c:(.text+0x280): multiple definition of `autofs_clean_ino'
> >    fs/autofs/inode.o:inode.c:(.text+0x280): first defined here
> 
> There's bot breakage here - clearly that patch didn't cause this error.
> 
> Ian, this autofs glitch may still not be fixed.

Yes, autofs-make-autofs4-Kconfig-depend-on-AUTOFS_FS.patch should have
fixed that.

I tied a bunch of .config combinations and I was unable to find any that
lead to both CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS being defined.

I must be missing something else, I'll investigate.

Ian

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 938C96B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:54:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v4so132845350pgc.20
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 16:54:23 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id k23si11406700pfg.41.2017.04.10.16.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Apr 2017 16:54:22 -0700 (PDT)
Date: Tue, 11 Apr 2017 09:54:18 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [mmotm:master 161/276] kernel/extable.c:174: undefined
 reference to `__start_ro_after_init'
Message-ID: <20170411095418.65bca085@canb.auug.org.au>
In-Reply-To: <20170410140955.5a82e6f0fcb784c03ddd305c@linux-foundation.org>
References: <201704081021.kBB1nNuC%fengguang.wu@intel.com>
	<20170410140955.5a82e6f0fcb784c03ddd305c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Eddie Kovsky <ewk@edkovsky.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

On Mon, 10 Apr 2017 14:09:55 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sat, 8 Apr 2017 10:37:22 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   5b220005fda0593464fc4549eea586e597bf783c
> > commit: 7c61156608a0054d57061bd154b1ac537c49e0a8 [161/276] extable: verify address is read-only
> > config: arm-efm32_defconfig (attached as .config)
> > compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> > reproduce:
> >         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 7c61156608a0054d57061bd154b1ac537c49e0a8
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=arm 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    kernel/built-in.o: In function `core_kernel_rodata':  
> > >> kernel/extable.c:174: undefined reference to `__start_ro_after_init'
> > >> kernel/extable.c:174: undefined reference to `__end_ro_after_init'  
> 
> Thanks, I dropped the patch.  And its companion
> module-verify-address-is-read-only.patch to keep things tidy.

Both removed from linux-next today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

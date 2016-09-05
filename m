Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFBD6B0253
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 22:18:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g185so23906802ith.3
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 19:18:27 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0219.hostedemail.com. [216.40.44.219])
        by mx.google.com with ESMTPS id e5si20026540itd.85.2016.09.04.19.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Sep 2016 19:18:26 -0700 (PDT)
Message-ID: <1473041902.5018.63.camel@perches.com>
Subject: Re: video-vga.c:undefined reference to `__gcov_init'
From: Joe Perches <joe@perches.com>
Date: Sun, 04 Sep 2016 19:18:22 -0700
In-Reply-To: <201609051030.SaJgm2Bj%fengguang.wu@intel.com>
References: <201609051030.SaJgm2Bj%fengguang.wu@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 2016-09-05 at 10:13 +0800, kbuild test robot wrote:
> Hi Joe,

Hi Fengguang

> FYI, the error/warning still remains.

Is this really my responsibility?
I don't think so.
I didn't submit this patch to stable.
I don't know nor care really who did,
but I think the robot should ping the
stable submitter.

cheers, Joe

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   c6935931c1894ff857616ff8549b61236a19148f
> commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
> date:   1 year, 2 months ago
> config: x86_64-rhel_gcov (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         git checkout cb984d101b30eb7478d32df56a0023e4603cba7f
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/x86/realmode/rm/video-vga.o:(.data+0x150): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/video-vga.o: In function `_GLOBAL__sub_I_65535_0_vga_crtc':
> > 
> > > 
> > > video-vga.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>    arch/x86/realmode/rm/wakemain.o:(.data+0x70): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/wakemain.o: In function `_GLOBAL__sub_I_65535_0_main':
> > 
> > > 
> > > wakemain.c:(.text.startup+0x1f4): undefined reference to `__gcov_init'
>    arch/x86/realmode/rm/video-mode.o:(.data+0x90): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/video-mode.o: In function `_GLOBAL__sub_I_65535_0_probe_cards':
> > 
> > > 
> > > video-mode.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>    arch/x86/realmode/rm/regs.o:(.data+0x30): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/regs.o: In function `_GLOBAL__sub_I_65535_0_initregs':
> > 
> > > 
> > > regs.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>    arch/x86/realmode/rm/video-vesa.o:(.data+0x70): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/video-vesa.o: In function `_GLOBAL__sub_I_65535_0_video_vesa.c':
> > 
> > > 
> > > video-vesa.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>    arch/x86/realmode/rm/video-bios.o:(.data+0x90): undefined reference to `__gcov_merge_add'
>    arch/x86/realmode/rm/video-bios.o: In function `_GLOBAL__sub_I_65535_0_video_bios.c':
> > 
> > > 
> > > video-bios.c:(.text.startup+0x7): undefined reference to `__gcov_init'
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

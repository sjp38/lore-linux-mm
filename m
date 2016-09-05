Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D31446B0038
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 22:28:21 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so352761711pad.2
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 19:28:21 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k12si26543321pag.93.2016.09.04.19.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Sep 2016 19:28:21 -0700 (PDT)
Date: Mon, 5 Sep 2016 10:28:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [kbuild-all] video-vga.c:undefined reference to `__gcov_init'
Message-ID: <20160905022814.r5wri6inejdlnbjm@wfg-t540p.sh.intel.com>
References: <201609051030.SaJgm2Bj%fengguang.wu@intel.com>
 <1473041902.5018.63.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1473041902.5018.63.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, linux-kernel@vger.kernel.org

Hi Joe,

On Sun, Sep 04, 2016 at 07:18:22PM -0700, Joe Perches wrote:
>On Mon, 2016-09-05 at 10:13 +0800, kbuild test robot wrote:
>> Hi Joe,
>
>Hi Fengguang
>
>> FYI, the error/warning still remains.
>
>Is this really my responsibility?
>I don't think so.
>I didn't submit this patch to stable.
>I don't know nor care really who did,
>but I think the robot should ping the
>stable submitter.

Sorry for the noise! This particular commit are obviously attributed
too many irrelevant errors. I'll just drop reports for this commit.

In this case it's not relevant to the stable maintainers?

Fengguang

>> tree:A A A https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:A A A c6935931c1894ff857616ff8549b61236a19148f
>> commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
>> date:A A A 1 year, 2 months ago
>> config: x86_64-rhel_gcov (attached as .config)
>> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>> A A A A A A A A git checkout cb984d101b30eb7478d32df56a0023e4603cba7f
>> A A A A A A A A # save the attached .config to linux build tree
>> A A A A A A A A make ARCH=x86_64A 
>>
>> All errors (new ones prefixed by >>):
>>
>> A A A arch/x86/realmode/rm/video-vga.o:(.data+0x150): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/video-vga.o: In function `_GLOBAL__sub_I_65535_0_vga_crtc':
>> >
>> > >
>> > > video-vga.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>> A A A arch/x86/realmode/rm/wakemain.o:(.data+0x70): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/wakemain.o: In function `_GLOBAL__sub_I_65535_0_main':
>> >
>> > >
>> > > wakemain.c:(.text.startup+0x1f4): undefined reference to `__gcov_init'
>> A A A arch/x86/realmode/rm/video-mode.o:(.data+0x90): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/video-mode.o: In function `_GLOBAL__sub_I_65535_0_probe_cards':
>> >
>> > >
>> > > video-mode.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>> A A A arch/x86/realmode/rm/regs.o:(.data+0x30): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/regs.o: In function `_GLOBAL__sub_I_65535_0_initregs':
>> >
>> > >
>> > > regs.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>> A A A arch/x86/realmode/rm/video-vesa.o:(.data+0x70): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/video-vesa.o: In function `_GLOBAL__sub_I_65535_0_video_vesa.c':
>> >
>> > >
>> > > video-vesa.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>> A A A arch/x86/realmode/rm/video-bios.o:(.data+0x90): undefined reference to `__gcov_merge_add'
>> A A A arch/x86/realmode/rm/video-bios.o: In function `_GLOBAL__sub_I_65535_0_video_bios.c':
>> >
>> > >
>> > > video-bios.c:(.text.startup+0x7): undefined reference to `__gcov_init'
>> ---
>> 0-DAY kernel test infrastructureA A A A A A A A A A A A A A A A Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-allA A A A A A A A A A A A A A A A A A A Intel Corporation
>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

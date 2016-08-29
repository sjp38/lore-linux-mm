Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B676E830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:25:53 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so267481829pad.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:25:53 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id bn10si39198809pac.174.2016.08.29.06.25.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 06:25:52 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/nobootmem.c: make CONFIG_NO_BOOTMEM depend on
 CONFIG_HAVE_MEMBLOCK
References: <201608281506.Wwpfh6ja%fengguang.wu@intel.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <88c16598-41ec-97dc-8a35-dad0ec763fbd@zoho.com>
Date: Mon, 29 Aug 2016 21:24:45 +0800
MIME-Version: 1.0
In-Reply-To: <201608281506.Wwpfh6ja%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: zijun_hu@htc.com, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

i am sorry, this patch has many bugs
i resend it in another mail thread
please ignore it

On 2016/8/28 15:48, kbuild test robot wrote:
> Hi zijun_hu,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.8-rc3 next-20160825]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
> 
> url:    https://github.com/0day-ci/linux/commits/zijun_hu/mm-nobootmem-c-make-CONFIG_NO_BOOTMEM-depend-on-CONFIG_HAVE_MEMBLOCK/20160827-233707
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: mips-allmodconfig (attached as .config)
> compiler: mips-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=mips 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/mips/built-in.o: In function `setup_arch':
>>> (.init.text+0x1ff4): undefined reference to `init_bootmem_node'
>    arch/mips/built-in.o: In function `setup_arch':
>>> (.init.text+0x2144): undefined reference to `reserve_bootmem'
>    arch/mips/built-in.o: In function `setup_arch':
>    (.init.text+0x21a8): undefined reference to `reserve_bootmem'
>    arch/mips/built-in.o: In function `setup_arch':
>    (.init.text+0x2220): undefined reference to `reserve_bootmem'
>    arch/mips/built-in.o: In function `setup_arch':
>    (.init.text+0x22a4): undefined reference to `reserve_bootmem'
>    arch/mips/built-in.o: In function `setup_arch':
>    (.init.text+0x22d8): undefined reference to `reserve_bootmem'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

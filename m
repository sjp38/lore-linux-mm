Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA16C6B007E
	for <linux-mm@kvack.org>; Sat,  4 Jun 2016 06:42:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so9290113wme.3
        for <linux-mm@kvack.org>; Sat, 04 Jun 2016 03:42:59 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id k197si5377283wmg.0.2016.06.04.03.42.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Jun 2016 03:42:58 -0700 (PDT)
Date: Sat, 4 Jun 2016 11:42:43 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [mmotm:master 152/178] include/linux/kexec.h:356:9: error:
 implicit declaration of function 'phys_to_virt'
Message-ID: <20160604104243.GG1041@n2100.armlinux.org.uk>
References: <201606041044.dTOHh5q4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606041044.dTOHh5q4%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jun 04, 2016 at 10:11:47AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   2e0066ec9585a5074c8040d639c3c669eb4e905f
> commit: 60c8a7d9e20b888121b304895074928bf9b69029 [152/178] kexec: allow architectures to override boot mapping
> config: sh-sh7785lcr_32bit_defconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 60c8a7d9e20b888121b304895074928bf9b69029
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from arch/sh/kernel/reboot.c:2:0:
>    include/linux/kexec.h: In function 'boot_phys_to_virt':
> >> include/linux/kexec.h:356:9: error: implicit declaration of function 'phys_to_virt' [-Werror=implicit-function-declaration]
>      return phys_to_virt(boot_phys_to_phys(entry));
>             ^

Is there a reason SH doesn't provide phys_to_virt()?  Isn't that a basic
requirement for every architecture?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

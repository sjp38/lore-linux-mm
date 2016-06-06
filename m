Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64CF56B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:31:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ug1so45143300pab.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:31:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xq1si3996448pab.157.2016.06.06.13.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:31:24 -0700 (PDT)
Date: Mon, 6 Jun 2016 13:31:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: undefined reference to `early_panic'
Message-Id: <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
In-Reply-To: <201606051227.HWQZ0zJJ%fengguang.wu@intel.com>
References: <201606051227.HWQZ0zJJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Chris Metcalf <cmetcalf@mellanox.com>

On Sun, 5 Jun 2016 12:33:29 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> It's probably a bug fix that unveils the link errors.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   049ec1b5a76d34a6980cccdb7c0baeb4eed7a993
> commit: 888cdbc2c9a76a0e450f533b1957cdbfe7d483d5 hugetlb: fix compile error on tile
> date:   5 months ago
> config: tile-allnoconfig (attached as .config)
> compiler: tilegx-linux-gcc (GCC) 4.6.2
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 888cdbc2c9a76a0e450f533b1957cdbfe7d483d5
>         # save the attached .config to linux build tree
>         make.cross ARCH=tile 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/tile/built-in.o: In function `setup_arch':
> >> (.init.text+0x15d8): undefined reference to `early_panic'
>    arch/tile/built-in.o: In function `setup_arch':
>    (.init.text+0x1610): undefined reference to `early_panic'
>    arch/tile/built-in.o: In function `setup_arch':
>    (.init.text+0x1800): undefined reference to `early_panic'
>    arch/tile/built-in.o: In function `setup_arch':
>    (.init.text+0x1828): undefined reference to `early_panic'
>    arch/tile/built-in.o: In function `setup_arch':
>    (.init.text+0x1bd8): undefined reference to `early_panic'
>    arch/tile/built-in.o:(.init.text+0x1c18): more undefined references to `early_panic' follow

This?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: tile: early_printk.o is always required

arch/tile/setup.o is always compiled, and it requires early_panic() and
hence early_printk(), so we must always build and link early_printk.o.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/tile/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff -puN arch/tile/Kconfig~tile-early_printko-is-always-required arch/tile/Kconfig
--- a/arch/tile/Kconfig~tile-early_printko-is-always-required
+++ a/arch/tile/Kconfig
@@ -14,6 +14,7 @@ config TILE
 	select GENERIC_FIND_FIRST_BIT
 	select GENERIC_IRQ_PROBE
 	select GENERIC_IRQ_SHOW
+	select EARLY_PRINTK
 	select GENERIC_PENDING_IRQ if SMP
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

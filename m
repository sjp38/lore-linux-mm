Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 971C26B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 15:52:53 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id lp2so170048174igb.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 12:52:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id zh6si18834044pab.23.2016.06.07.12.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 12:52:52 -0700 (PDT)
Date: Tue, 7 Jun 2016 12:52:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: tile: early_printk.o is always required
Message-Id: <20160607125245.79a26fd3fee40afaa8ca04ff@linux-foundation.org>
In-Reply-To: <201606071706.sPPjN9gM%fengguang.wu@intel.com>
References: <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
	<201606071706.sPPjN9gM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Chris Metcalf <cmetcalf@mellanox.com>

On Tue, 7 Jun 2016 17:17:49 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi,
> 
> [auto build test ERROR on tile/master]
> [also build test ERROR on v4.7-rc2 next-20160606]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Andrew-Morton/tile-early_printk-o-is-always-required/20160607-043356
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git master
> config: tile-allnoconfig (attached as .config)
> compiler: tilegx-linux-gcc (GCC) 4.6.2
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=tile 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/tile/built-in.o: In function `early_hv_write':
> >> early_printk.c:(.text+0xc770): undefined reference to `tile_console_write'
>    early_printk.c:(.text+0xc800): undefined reference to `tile_console_write'

Which means we also need HVC_TILE which means we need TTY which means...

blah, I give up :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

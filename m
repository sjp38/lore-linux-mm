Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B01128024B
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 23:46:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j28so227526524iod.2
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 20:46:30 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0038.hostedemail.com. [216.40.44.38])
        by mx.google.com with ESMTPS id n4si14607559ioo.158.2016.09.24.20.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 20:46:29 -0700 (PDT)
Message-ID: <1474775186.23838.23.camel@perches.com>
Subject: Re: undefined reference to `printk'
From: Joe Perches <joe@perches.com>
Date: Sat, 24 Sep 2016 20:46:26 -0700
In-Reply-To: <201609251139.vxagmOPP%fengguang.wu@intel.com>
References: <201609251139.vxagmOPP%fengguang.wu@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, 2016-09-25 at 11:40 +0800, kbuild test robot wrote:
> Hi Joe,

Hey Fengguang

> It's probably a bug fix that unveils the link errors.

I think all of these reports about compiler-gcc integrations
are bogons.

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   9c0e28a7be656d737fb18998e2dcb0b8ce595643
> commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
> date:   1 year, 3 months ago
> config: m32r-allnoconfig (attached as .config)
> compiler: m32r-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout cb984d101b30eb7478d32df56a0023e4603cba7f
>         # save the attached .config to linux build tree
>         make.cross ARCH=m32r 
> 
> 
> All errors (new ones prefixed by >>):
> 
> 
>    arch/m32r/kernel/built-in.o: In function `default_eit_handler':
> > > (.text+0x3fc): undefined reference to `printk'

There isn't any association to integration here.

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

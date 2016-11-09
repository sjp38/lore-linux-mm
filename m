Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 171316B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 15:50:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so110126281wmu.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 12:50:13 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id h5si1427160wjj.224.2016.11.09.12.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 12:50:11 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id g23so381710wme.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 12:50:11 -0800 (PST)
Message-ID: <58238BFD.6000703@gmail.com>
Date: Wed, 09 Nov 2016 20:50:05 +0000
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
MIME-Version: 1.0
Subject: Re: [linux-next:master 5015/5173] include/drm/drmP.h:178:2: note:
 in expansion of macro '_DRM_PRINTK'
References: <201611091657.OOsciPLy%fengguang.wu@intel.com>
In-Reply-To: <201611091657.OOsciPLy%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wednesday 09 November 2016 08:46 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   6b9ac964c292bfc0f8e948392ec1914e40abae63
> commit: ae751ceb4237be6781b205ab196ef887a2836cf2 [5015/5173] m32r: add simple dma
> config: m32r-allmodconfig (attached as .config)
> compiler: m32r-linux-gcc (GCC) 6.2.0
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          git checkout ae751ceb4237be6781b205ab196ef887a2836cf2
>          # save the attached .config to linux build tree
>          make.cross ARCH=m32r
>
> All warnings (new ones prefixed by >>):

well, they were never built with m32r before. I will try to fix them as 
much as possible.

Regards
Sudip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

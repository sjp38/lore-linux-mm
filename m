Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 997936B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:21:53 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so11564234oih.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:21:53 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id f63si5052676oic.182.2017.08.14.09.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:21:52 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id g35so40018751ioi.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:21:52 -0700 (PDT)
Date: Mon, 14 Aug 2017 10:21:50 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v5 10/10] lkdtm: Add test for XPFO
Message-ID: <20170814162150.ccq574wyt5ucuazn@smitten>
References: <20170809200755.11234-11-tycho@docker.com>
 <201708130449.P9mhc7yi%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708130449.P9mhc7yi%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Sun, Aug 13, 2017 at 04:24:23AM +0800, kbuild test robot wrote:
> Hi Juerg,
> 
> [auto build test ERROR on arm64/for-next/core]
> [also build test ERROR on v4.13-rc4]
> [cannot apply to next-20170811]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Tycho-Andersen/Add-support-for-eXclusive-Page-Frame-Ownership/20170813-035705
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core
> config: x86_64-randconfig-x016-201733 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/misc/lkdtm_xpfo.c: In function 'read_user_with_flags':
> >> drivers/misc/lkdtm_xpfo.c:31:14: error: implicit declaration of function 'user_virt_to_phys' [-Werror=implicit-function-declaration]
>      phys_addr = user_virt_to_phys(user_addr);
>                  ^~~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors

These are both the same error, looks like I forgot a dummy prototype
in the non CONFIG_XPFO case, I'll fix it in the next version.

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7E696B0261
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:54:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so74856812pfv.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:54:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q2si41931518pfb.213.2016.09.07.09.33.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 09:33:06 -0700 (PDT)
Date: Wed, 7 Sep 2016 19:33:03 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] ipc/shm: fix crash if CONFIG_SHMEM is not set
Message-ID: <20160907163303.GA99854@black.fi.intel.com>
References: <20160907111452.GA138665@black.fi.intel.com>
 <201609072221.M7OSrgbL%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609072221.M7OSrgbL%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Tony Battersby <tonyb@cybernetics.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, Sep 07, 2016 at 10:28:56PM +0800, kbuild test robot wrote:
> Hi Kirill,
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.8-rc5 next-20160907]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
> 
> url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/ipc-shm-fix-crash-if-CONFIG_SHMEM-is-not-set/20160907-204216
> config: sh-rsk7201_defconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All errors (new ones prefixed by >>):
> 
>    ipc/shm.c: In function 'shm_get_unmapped_area':
> >> ipc/shm.c:477:25: error: 'struct mm_struct' has no member named 'get_unmapped_area'
>       get_area = current->mm->get_unmapped_area;

Urghh... no-MMU..

This should work for them too.

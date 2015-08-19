Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id CAC3E6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:33:07 -0400 (EDT)
Received: by iodv127 with SMTP id v127so24837695iod.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 14:33:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o135si1679991ioo.195.2015.08.19.14.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 14:33:06 -0700 (PDT)
Date: Wed, 19 Aug 2015 14:33:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 9078/9582]
 arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE"
 redefined
Message-Id: <20150819143305.fc1fbb979fee6e9b60c59d3c@linux-foundation.org>
In-Reply-To: <201508192138.toXxw84b%fengguang.wu@intel.com>
References: <201508192138.toXxw84b%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 19 Aug 2015 21:32:40 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   dcaa9a3e88c4082096bfed62d9de2d9b6ad9e3d6
> commit: 878b6f5bcef8de64a5c39b685e785166357bf0dc [9078/9582] mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status-fix-3
> config: arm64-allmodconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 878b6f5bcef8de64a5c39b685e785166357bf0dc
>   # save the attached .config to linux build tree
>   make.cross ARCH=arm64 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/mm.h:54:0,
>                     from arch/arm64/kernel/asm-offsets.c:22:
> >> arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE" redefined
>     #define HUGE_MAX_HSTATE  2
>     ^
>    In file included from include/linux/sched.h:27:0,
>                     from arch/arm64/kernel/asm-offsets.c:21:
>    include/linux/mm_types.h:372:0: note: this is the location of the previous definition
>     #define HUGE_MAX_HSTATE 1

I've spent far too long trying to come up with a nice fix for this and
everything I try leads down a path of horror.  Our include files are a
big mess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

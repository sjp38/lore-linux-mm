Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7D66B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 10:41:06 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id z12so6377102lbi.9
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:41:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si18970858lae.49.2014.09.23.07.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 07:41:04 -0700 (PDT)
Date: Tue, 23 Sep 2014 16:41:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [mmotm:master 169/385] mm/debug.c:215:5: error: 'const struct
 mm_struct' has no member named 'owner'
Message-ID: <20140923144101.GB10114@dhcp22.suse.cz>
References: <5420ccd5.miNNRyVn5wct+fk+%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5420ccd5.miNNRyVn5wct+fk+%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

JFYI: Posted a fix here already:
http://marc.info/?l=linux-mm&m=141146435524579&w=2

On Tue 23-09-14 09:28:53, Wu Fengguang wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   eb076320e4dbdf99513732811ed8730812b34b2f
> commit: bac27df2312993aedf1cdfa2dad43e5aeb29504d [169/385] mm: introduce VM_BUG_ON_MM
> config: arm-tegra_defconfig
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout bac27df2312993aedf1cdfa2dad43e5aeb29504d
>   make.cross ARCH=arm  tegra_defconfig
>   make.cross ARCH=arm 
> 
> All error/warnings:
> 
>    mm/debug.c: In function 'dump_mm':
> >> mm/debug.c:215:5: error: 'const struct mm_struct' has no member named 'owner'
>       mm->owner, mm->exe_file,
>         ^
> 
> vim +215 mm/debug.c
> 
>    209			mm->start_brk, mm->brk, mm->start_stack,
>    210			mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
>    211			mm->binfmt, mm->flags, mm->core_state,
>    212	#ifdef CONFIG_AIO
>    213			mm->ioctx_table,
>    214	#endif
>  > 215			mm->owner, mm->exe_file,
>    216	#ifdef CONFIG_MMU_NOTIFIER
>    217			mm->mmu_notifier_mm,
>    218	#endif
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

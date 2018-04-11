Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF7CB6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 07:33:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g61-v6so1042243plb.10
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:33:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u37si636155pgn.702.2018.04.11.04.33.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 04:33:51 -0700 (PDT)
Date: Wed, 11 Apr 2018 13:33:49 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:since-4.16 207/224] arch/tile/mm/mmap.c:53:6: error:
 conflicting types for 'arch_pick_mmap_layout'
Message-ID: <20180411113349.GI23400@dhcp22.suse.cz>
References: <201804111943.GtB7X93z%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804111943.GtB7X93z%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Kees Cook <keescook@chromium.org>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 11-04-18 19:16:50, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.16
> head:   e5edc6faef45baae632fc4c76096a2ab69145c11
> commit: a18ed29e39bde6c1aaf0fb449732ba8423bc5964 [207/224] exec: pass stack rlimit into mm layout functions
> config: tile-tilegx_defconfig (attached as .config)
> compiler: tilegx-linux-gcc (GCC) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout a18ed29e39bde6c1aaf0fb449732ba8423bc5964
>         # save the attached .config to linux build tree
>         make.cross ARCH=tile 
> 
> All errors (new ones prefixed by >>):
> 
> >> arch/tile/mm/mmap.c:53:6: error: conflicting types for 'arch_pick_mmap_layout'
>     void arch_pick_mmap_layout(struct mm_struct *mm)

Isn't tile dead? Does it make any sense to compile test it?
-- 
Michal Hocko
SUSE Labs

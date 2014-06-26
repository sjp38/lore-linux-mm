Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0666B00A8
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 16:02:25 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so3540731iec.14
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 13:02:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bl5si13063070icb.36.2014.06.26.13.02.24
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 13:02:24 -0700 (PDT)
Date: Thu, 26 Jun 2014 13:02:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 108/319] kernel/events/uprobes.c:319:2: error:
 implicit declaration of function 'mem_cgroup_charge_anon'
Message-Id: <20140626130223.2db7a085421f594eb1707eb8@linux-foundation.org>
In-Reply-To: <53ab71c4.YGFc6XN+rgscOdCJ%fengguang.wu@intel.com>
References: <53ab71c4.YGFc6XN+rgscOdCJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Thu, 26 Jun 2014 09:05:08 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
> commit: 5c83b35612a2f2894b54d902ac50612cec2e1926 [108/319] mm: memcontrol: rewrite charge API
> config: i386-randconfig-ha2-0626 (attached as .config)
> 
> Note: the mmotm/master HEAD 9477ec75947f2cf0fc47e8ab781a5e9171099be2 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    kernel/events/uprobes.c: In function 'uprobe_write_opcode':
> >> kernel/events/uprobes.c:319:2: error: implicit declaration of function 'mem_cgroup_charge_anon' [-Werror=implicit-function-declaration]
>      if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))
>      ^
>    cc1: some warnings being treated as errors

The next patch mm-memcontrol-rewrite-charge-api-fix-3.patch fixes this
up.  Is there something I did which fooled the buildbot's
hey-theres-a-fixup-patch detector?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

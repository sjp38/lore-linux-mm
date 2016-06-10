Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 831426B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 05:01:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so102004983pfa.2
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:01:58 -0700 (PDT)
Received: from out1134-227.mail.aliyun.com (out1134-227.mail.aliyun.com. [42.120.134.227])
        by mx.google.com with ESMTP id ss2si11615000pab.111.2016.06.10.02.01.56
        for <linux-mm@kvack.org>;
        Fri, 10 Jun 2016 02:01:57 -0700 (PDT)
Message-ID: <575A836A.5000606@emindsoft.com.cn>
Date: Fri, 10 Jun 2016 17:07:54 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/memory_hotplug.h: Clean up code
References: <201606101451.xfKpSBrt%fengguang.wu@intel.com>
In-Reply-To: <201606101451.xfKpSBrt%fengguang.wu@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, trivial@kernel.org, mhocko@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, baiyaowei@cmss.chinamobile.com, vkuznets@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 6/10/16 14:11, kbuild test robot wrote:
> Hi,
> 
> [auto build test ERROR on next-20160609]
> [also build test ERROR on v4.7-rc2]
> [cannot apply to v4.7-rc2 v4.7-rc1 v4.6-rc7]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 

Oh, my patch is for linux-next 20160609 tree, can not apply to v4.7-rc2
directly.

[...]

> 
>    In file included from include/linux/mmzone.h:741:0,
>                     from include/linux/gfp.h:5,
>                     from include/linux/kmod.h:22,
>                     from include/linux/module.h:13,
>                     from include/linux/moduleloader.h:5,
>                     from arch/blackfin/kernel/module.c:9:
>    include/linux/memory_hotplug.h: In function 'mhp_notimplemented':
>>> include/linux/memory_hotplug.h:225:2: error: 'mod' undeclared (first use in this function)
>    include/linux/memory_hotplug.h:225:2: note: each undeclared identifier is reported only once for each function it appears in
> 
> vim +/mod +225 include/linux/memory_hotplug.h
> 
>    219	static inline void zone_span_writelock(struct zone *zone) {}
>    220	static inline void zone_span_writeunlock(struct zone *zone) {}
>    221	static inline void zone_seqlock_init(struct zone *zone) {}
>    222	
>    223	static inline int mhp_notimplemented(const char *func)
>    224	{
>  > 225		pr_warn("%s() called, with CONFIG_MEMORY_HOTPLUG disabled\n", func);
>    226		dump_stack();
>    227		return -ENOSYS;
>    228	}
> 

After "grep -rn pr_fmt * | grep define" under arch/, for me, it is
blackfin's issue:

  we need use

    #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

  instead of

    #define pr_fmt(fmt) "module %s: " fmt, mod->name

I shall send one blackfin patch for it.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

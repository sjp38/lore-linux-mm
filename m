Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66E1D6B026C
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 08:27:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 44so91712790qtf.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 05:27:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b128si15320595ybc.144.2016.09.08.05.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 05:27:34 -0700 (PDT)
Date: Thu, 8 Sep 2016 14:26:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [sashal-linux-stable-security:linux-3.12.y-security 590/1388]
	mm/util.c:277:3: error: implicit declaration of function
	'for_each_thread'
Message-ID: <20160908122650.GB15874@redhat.com>
References: <201609080220.fropEFaF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609080220.fropEFaF%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On 09/08, kbuild test robot wrote:
>
> Hi Oleg,
>
> FYI, the error/warning still remains.

I guess this is because you need to backport for_each_thread first ;)

And probably a couple more commits before this one.

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/sashal/linux-stable-security.git linux-3.12.y-security
> head:   aac46739e3b30a5e6a0ccb2820dfde1333e9f24b
> commit: 9ac1e8708f42427bffe12c0f7f0813efe730a29d [590/1388] vm_is_stack: use for_each_thread() rather then buggy while_each_thread()
> config: i386-randconfig-s1-201636 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.3-14) 4.9.3
> reproduce:
>         git checkout 9ac1e8708f42427bffe12c0f7f0813efe730a29d
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/util.c: In function 'vm_is_stack':
> >> mm/util.c:277:3: error: implicit declaration of function 'for_each_thread' [-Werror=implicit-function-declaration]
>       for_each_thread(task, t) {
>       ^
> >> mm/util.c:277:28: error: expected ';' before '{' token
>       for_each_thread(task, t) {
>                                ^
>    cc1: some warnings being treated as errors
> 
> vim +/for_each_thread +277 mm/util.c
> 
>    271			return task->pid;
>    272	
>    273		if (in_group) {
>    274			struct task_struct *t;
>    275	
>    276			rcu_read_lock();
>  > 277			for_each_thread(task, t) {
>    278				if (vm_is_stack_for_task(t, vma)) {
>    279					ret = t->pid;
>    280					goto done;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

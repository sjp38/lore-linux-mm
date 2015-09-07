Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 50C896B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 10:01:44 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so89803659wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 07:01:44 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id et11si14264426wjc.120.2015.09.07.07.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 07:01:43 -0700 (PDT)
Date: Mon, 7 Sep 2015 16:01:42 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: fs/ocfs2/dlm/dlmrecovery.c:1824:4-23: iterator with update on
 line 1827
In-Reply-To: <201509072033.3vy462XZ%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.10.1509071559590.2407@hadrien>
References: <201509072033.3vy462XZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, joseph.qi@huawei.com, kbuild-all@01.org, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: kbuild@01.org

It looks like a serious problem, because the loop update does a
dereference of the first argument of list_for_each via list_entry.

julia

On Mon, 7 Sep 2015, kbuild test robot wrote:

> TO: Joseph Qi <joseph.qi@huawei.com>
> CC: kbuild-all@01.org
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Linux Memory Management List <linux-mm@kvack.org>
>
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   7d9071a095023cd1db8fa18fa0d648dc1a5210e0
> commit: f83c7b5e9fd633fe91128af116e6472a8c4d29a5 ocfs2/dlm: use list_for_each_entry instead of list_for_each
> date:   3 days ago
> :::::: branch date: 33 hours ago
> :::::: commit date: 3 days ago
>
> >> fs/ocfs2/dlm/dlmrecovery.c:1824:4-23: iterator with update on line 1827
>
> git remote add linus git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> git remote update linus
> git checkout f83c7b5e9fd633fe91128af116e6472a8c4d29a5
> vim +1824 fs/ocfs2/dlm/dlmrecovery.c
>
> 6714d8e8 Kurt Hackel 2005-12-15  1818  			BUG_ON(!(mres->flags & DLM_MRES_MIGRATION));
> 6714d8e8 Kurt Hackel 2005-12-15  1819
> 34aa8dac Junxiao Bi  2014-04-03  1820  			lock = NULL;
> 6714d8e8 Kurt Hackel 2005-12-15  1821  			spin_lock(&res->spinlock);
> e17e75ec Kurt Hackel 2007-01-05  1822  			for (j = DLM_GRANTED_LIST; j <= DLM_BLOCKED_LIST; j++) {
> e17e75ec Kurt Hackel 2007-01-05  1823  				tmpq = dlm_list_idx_to_ptr(res, j);
> f83c7b5e Joseph Qi   2015-09-04 @1824  				list_for_each_entry(lock, tmpq, list) {
> 34aa8dac Junxiao Bi  2014-04-03  1825  					if (lock->ml.cookie == ml->cookie)
> 6714d8e8 Kurt Hackel 2005-12-15  1826  						break;
> 34aa8dac Junxiao Bi  2014-04-03 @1827  					lock = NULL;
> 6714d8e8 Kurt Hackel 2005-12-15  1828  				}
> e17e75ec Kurt Hackel 2007-01-05  1829  				if (lock)
> e17e75ec Kurt Hackel 2007-01-05  1830  					break;
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C84816B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 20:26:25 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8H0QR30027350
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Sep 2010 09:26:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BA9345DE50
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:26:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 655A845DE4E
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:26:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BEE21DB8037
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:26:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E16FD1DB8049
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:26:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFCv2][PATCH] add some drop_caches documentation and info messsge
In-Reply-To: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
References: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
Message-Id: <20100917092603.3BD5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Sep 2010 09:26:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com
List-ID: <linux-mm.kvack.org>

> diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-16 09:43:52.000000000 -0700
> +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-16 09:43:52.000000000 -0700
> @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
>  {
>  	proc_dointvec_minmax(table, write, buffer, length, ppos);
>  	if (write) {
> +		printk(KERN_NOTICE "%s (%d): dropped kernel caches: %d\n",
> +			current->comm, task_pid_nr(current), sysctl_drop_caches);
>  		if (sysctl_drop_caches & 1)
>  			iterate_supers(drop_pagecache_sb, NULL);
>  		if (sysctl_drop_caches & 2)

Can't you print it only once?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

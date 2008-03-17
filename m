Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HKtQGD001903
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:55:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HKtQPI192304
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:55:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HKtQUE028212
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:55:26 -0600
Subject: Re: [PATCH] a fix for procfs-task-exe-symlink.patch
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20080317004330.6D4441E7958@siro.lan>
References: <20080317004330.6D4441E7958@siro.lan>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 13:55:24 -0700
Message-Id: <1205787324.1175.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, minoura@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 09:43 +0900, YAMAMOTO Takashi wrote:
> it seems that procfs-task-exe-symlink.patch broke the case of
> dup_mmap failure.  ie. mm->exe_file is copied by memcpy from oldmm
> and then be fput'ed by mmput/set_mm_exe_file.
> 
> YAMAMOTO Takashi
> 
> 
> Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> ---
> 
> --- linux-2.6.25-rc3-mm1/kernel/fork.c.BACKUP	2008-03-05 15:45:50.000000000 +0900
> +++ linux-2.6.25-rc3-mm1/kernel/fork.c	2008-03-17 09:17:39.000000000 +0900
> @@ -523,11 +526,12 @@ static struct mm_struct *dup_mm(struct t
>  	if (init_new_context(tsk, mm))
>  		goto fail_nocontext;
> 
> +	dup_mm_exe_file(oldmm, mm);
> +
>  	err = dup_mmap(mm, oldmm);
>  	if (err)
>  		goto free_pt;
> 
> -	dup_mm_exe_file(oldmm, mm);
>  	mm->hiwater_rss = get_mm_rss(mm);
>  	mm->hiwater_vm = mm->total_vm;
> 

Acked-by: Matt Helsley <matthltc@us.ibm.com>

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

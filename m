In-reply-to: <12006091213248-git-send-email-salikhmetov@gmail.com> (message
	from Anton Salikhmetov on Fri, 18 Jan 2008 01:31:57 +0300)
Subject: Re: [PATCH -v6 1/2] Massive code cleanup of sys_msync()
References: <12006091182260-git-send-email-salikhmetov@gmail.com> <12006091213248-git-send-email-salikhmetov@gmail.com>
Message-Id: <E1JFnbj-0008SD-57@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 18 Jan 2008 10:33:51 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

>  	unsigned long end;
> -	struct mm_struct *mm = current->mm;
> +	int error, unmapped_error;
>  	struct vm_area_struct *vma;
> -	int unmapped_error = 0;
> -	int error = -EINVAL;
> +	struct mm_struct *mm;
>  
> +	error = -EINVAL;

I think you may have misunderstood my last comment.  These are OK:

	struct mm_struct *mm = current->mm;
	int unmapped_error = 0;
	int error = -EINVAL;

This is not so good:

	int error, unmapped_error;

This is the worst:

	int error = -EINVAL, unmapped_error = 0;

So I think the original code is fine as it is.

Othewise patch looks OK now.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

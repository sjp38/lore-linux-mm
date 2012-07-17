Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 654F66B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:28:12 -0400 (EDT)
Date: Tue, 17 Jul 2012 09:28:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4 v2] mm: fix possible incorrect return value of
 migrate_pages() syscall
In-Reply-To: <1342528415-2291-2-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207170925250.13599@router.home>
References: <Yes> <1342528415-2291-1-git-send-email-js1304@gmail.com> <1342528415-2291-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>

On Tue, 17 Jul 2012, Joonsoo Kim wrote:

> @@ -1382,6 +1382,8 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
>
>  	err = do_migrate_pages(mm, old, new,
>  		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
> +	if (err > 0)
> +		err = -EBUSY;
>
>  	mmput(mm);
>  out:

Why not have do_migrate_pages() return EBUSY if we do not need the number
of failed/retried pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

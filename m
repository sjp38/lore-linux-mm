Date: Wed, 13 Aug 2003 09:16:41 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test3-mm2
Message-ID: <22380000.1060791398@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.44.0308131529200.1558-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0308131529200.1558-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> --- 2.6.0-test3-mm2/mm/filemap.c	Wed Aug 13 11:51:33 2003
> +++ linux/mm/filemap.c	Wed Aug 13 15:26:36 2003
> @@ -1927,8 +1927,6 @@ generic_file_aio_write_nolock(struct kio
>  	ssize_t ret;
>  	loff_t pos = *ppos;
>  
> -	BUG_ON(iocb->ki_pos != *ppos);
> -
>  	if (!iov->iov_base && !is_sync_kiocb(iocb)) {
>  		/* nothing to transfer, may just need to sync data */
>  		ret = iov->iov_len; /* vector AIO not supported yet */

Even with this, still hangs when "mostly-booted". alt+sysrq+t doesn't
work, but ping does, oddly enough. I suppose I'll play with nmi_watchdog
or something later, but I doubt I'll have time today.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

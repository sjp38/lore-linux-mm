Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6D3826B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 12:41:47 -0500 (EST)
Received: by vcge1 with SMTP id e1so7692755vcg.14
        for <linux-mm@kvack.org>; Thu, 22 Dec 2011 09:41:46 -0800 (PST)
Message-ID: <4EF36BDA.5080105@gmail.com>
Date: Thu, 22 Dec 2011 12:41:46 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap system call does not return EOVERFLOW
References: <4EF2F9EB.7000006@jp.fujitsu.com>
In-Reply-To: <4EF2F9EB.7000006@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

> The argument "offset" is shifted right by PAGE_SHIFT bits
> in sys_mmap(mmap systemcall).
> 
> ------------------------------------------------------------------------
> sys_mmap(unsigned long addr, unsigned long len,
> 	unsigned long prot, unsigned long flags,
> 	unsigned long fd, unsigned long off)
> {
> 	error = sys_mmap_pgoff(addr, len, prot, flags, fd, off>>  PAGE_SHIFT);
> }
> ------------------------------------------------------------------------

Hm.
Which version are you looking at? Current code seems to don't have
sys_mmap().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

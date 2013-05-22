Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id CFCAB6B00BF
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:02:07 -0400 (EDT)
Date: Wed, 22 May 2013 10:01:42 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v7 2/8] vmcore: allocate buffer for ELF headers on
 page-size alignment
Message-ID: <20130522140142.GD5332@redhat.com>
References: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
 <20130522025543.12215.27624.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130522025543.12215.27624.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Wed, May 22, 2013 at 11:55:43AM +0900, HATAYAMA Daisuke wrote:

[..]
>  /* Sets offset fields of vmcore elements. */
> -static void __init set_vmcore_list_offsets_elf64(char *elfptr,
> +static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
>  						struct list_head *vc_list)
>  {
>  	loff_t vmcore_off;
> @@ -469,8 +472,7 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr,
>  	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>  
>  	/* Skip Elf header and program headers. */
> -	vmcore_off = sizeof(Elf64_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr);
> +	vmcore_off = elfsz;

As you are passing in size of elf headers, I think some of the code
has become redundant in this function. (ehdr_ptr = (Elf64_Ehdr *)elfptr;).
We can remove it and now we should be able to merge
set_vmcore_list_offsets_elf32() and set_vmcore_list_offsets_elf64()
functions.

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

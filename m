Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DB7916B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 16:32:45 -0400 (EDT)
Date: Thu, 16 May 2013 16:32:36 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 6/8] vmcore: allocate ELF note segment in the 2nd
 kernel vmalloc memory
Message-ID: <20130516203236.GG5904@redhat.com>
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
 <20130515090614.28109.26492.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130515090614.28109.26492.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Wed, May 15, 2013 at 06:06:14PM +0900, HATAYAMA Daisuke wrote:

[..]

> +static int __init get_note_number_and_size_elf32(const Elf32_Ehdr *ehdr_ptr,
> +						 int *nr_ptnote, u64 *phdr_sz)
> +{
> +	return process_note_headers_elf32(ehdr_ptr, nr_ptnote, phdr_sz, NULL);
> +}
> +
> +static int __init copy_notes_elf32(const Elf32_Ehdr *ehdr_ptr, char *notes_buf)
> +{
> +	return process_note_headers_elf32(ehdr_ptr, NULL, NULL, notes_buf);
> +}
> +

Please don't do this. We need to create two separate functions doing
two different operations and not just create wrapper around a function
which does two things.

I know both functions will have similar for loops for going through
the elf notes but it is better then doing function overloading based
on parameters passed.

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 20EF66B0073
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:58:03 -0400 (EDT)
Date: Tue, 14 May 2013 11:57:55 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v5 5/8] vmcore: allocate ELF note segment in the 2nd
 kernel vmalloc memory
Message-ID: <20130514155755.GH13674@redhat.com>
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
 <20130514015734.18697.32447.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514015734.18697.32447.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

On Tue, May 14, 2013 at 10:57:35AM +0900, HATAYAMA Daisuke wrote:

[..]
> +/* Merges all the PT_NOTE headers into one. */
> +static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
> +					   char **notesegptr, size_t *notesegsz,
> +					   struct list_head *vc_list)
> +{

Given that we are copying notes in second kernel, we are not using vc_list
in merge_note_headers() any more. So remove vc_list from paramter list
here.

For local parameters we could simply use notes_buf (instead of notesgptr)
and notes_sz (instead of notesgsz). It seems mroe readable.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

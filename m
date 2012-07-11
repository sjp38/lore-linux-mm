Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id AEDE56B0069
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 01:51:04 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SoppG-00089x-Jl
	for linux-mm@kvack.org; Wed, 11 Jul 2012 07:51:02 +0200
Received: from 112.132.141.1 ([112.132.141.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 07:51:02 +0200
Received: from xiyou.wangcong by 112.132.141.1 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 07:51:02 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
 /dev/shmem
Date: Wed, 11 Jul 2012 05:50:51 +0000 (UTC)
Message-ID: <jtj47r$tb7$1@dough.gmane.org>
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com>
 <1341845199-25677-2-git-send-email-nzimmer@sgi.com>
 <1341845199-25677-3-git-send-email-nzimmer@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Mon, 09 Jul 2012 at 14:46 GMT, Nathan Zimmer <nzimmer@sgi.com> wrote:
> +static unsigned long shmem_interleave(struct vm_area_struct *vma,
> +					unsigned long addr)
> +{
> +	unsigned long offset;
> +
> +	/* Use the vm_files prefered node as the initial offset. */
> +	offset = (unsigned long *) vma->vm_private_data;
> +

offset is 'unsigned long', but here you cast ->private_data to 'unsigned
long *'?? Please test your patches before posting.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

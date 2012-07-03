Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 637106B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 08:49:54 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Sm2Y7-0007KL-ME
	for linux-mm@kvack.org; Tue, 03 Jul 2012 14:49:48 +0200
Received: from 117.57.172.73 ([117.57.172.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 14:49:47 +0200
Received: from xiyou.wangcong by 117.57.172.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 14:49:47 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2 v4][rfc] tmpfs: interleave the starting node of
 /dev/shmem
Date: Tue, 3 Jul 2012 12:49:26 +0000 (UTC)
Message-ID: <jsupok$ik1$1@dough.gmane.org>
References: <20120702202635.GA20284@gulag1.americas.sgi.com>
 <20120702202857.GB15696@gulag1.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Mon, 02 Jul 2012 at 20:28 GMT, Nathan Zimmer <nzimmer@sgi.com> wrote:
> +static unsigned long shmem_interleave( struct vm_area_struct *vma, unsigned long addr)
> +{
> +	unsigned offset;
> +

Here, 'offset' should be 'unsigned long', 'unsigned' means 'unsigned
int'.


> +	// Use the vm_files prefered node as the initial offset
> +	offset = (unsigned long)vma->vm_private_data;
> +
> +	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +
> +	return offset;
> +}


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

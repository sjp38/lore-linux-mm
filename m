Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SKbllH027864
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:37:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SKbeDv159944
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:37:40 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SKbdqS008889
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:37:39 -0400
Subject: Re: [PATCH 4/5 V2] Build hugetlb backed process stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <34bf5c7a2116bc6bd16b4235bc1cf84395ee561e.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	 <34bf5c7a2116bc6bd16b4235bc1cf84395ee561e.1216928613.git.ebmunson@us.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 13:37:38 -0700
Message-Id: <1217277458.23502.39.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Munson <ebmunson@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 12:17 -0700, Eric Munson wrote:
> 
> +static int move_to_huge_pages(struct linux_binprm *bprm,
> +                               struct vm_area_struct *vma, unsigned
> long shift)
> +{
> +       struct mm_struct *mm = vma->vm_mm;
> +       struct vm_area_struct *new_vma;
> +       unsigned long old_end = vma->vm_end;
> +       unsigned long old_start = vma->vm_start;
> +       unsigned long new_end = old_end - shift;
> +       unsigned long new_start, length;
> +       unsigned long arg_size = new_end - bprm->p;
> +       unsigned long flags = vma->vm_flags;
> +       struct file *hugefile = NULL;
> +       unsigned int stack_hpages = 0;
> +       struct page **from_pages = NULL;
> +       struct page **to_pages = NULL;
> +       unsigned long num_pages = (arg_size / PAGE_SIZE) + 1;
> +       int ret;
> +       int i;
> +
> +#ifdef CONFIG_STACK_GROWSUP

Why do you have the #ifdef for the CONFIG_STACK_GROWSUP=y case in that
first patch if you don't support CONFIG_STACK_GROWSUP=y?

I think it might be worth some time to break this up a wee little bit.
16 local variables is a big on the beefy side. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

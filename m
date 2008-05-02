Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42HBVUg008293
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:11:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42HBVAa242864
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:11:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42HBUh8004646
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:11:30 -0400
Subject: Re: [RFC][PATCH 2/2] Add huge page backed stack support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
References: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
Content-Type: text/plain
Date: Fri, 02 May 2008 10:11:26 -0700
Message-Id: <1209748286.7763.34.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebmunson@us.ibm.com
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote:
> 
> +       if (!(get_personality & HUGE_PAGE_STACK)) {
>  #ifdef CONFIG_STACK_GROWSUP
> -       stack_base = vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
> +               stack_base = vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
>  #else
> -       stack_base = vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
> +               stack_base = vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
>  #endif
> -       ret = expand_stack(vma, stack_base);
> -       if (ret)
> -               ret = -EFAULT;
> +
> +               ret = expand_stack(vma, stack_base);
> +               if (ret)
> +                       ret = -EFAULT;
> +       }

Why don't huge page stacks need to be expanded like this?  With a large
EXTRA_STACK_VM_PAGES, you would surely need this, right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SK9tUD031431
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:09:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SK9sjQ176984
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 14:09:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SK9sHx023158
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 14:09:54 -0600
Subject: Re: [PATCH 1/5 V2] Align stack boundaries based on personality
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <6061445882ce9574999bf343eeb333be02a1afa6.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	 <6061445882ce9574999bf343eeb333be02a1afa6.1216928613.git.ebmunson@us.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 13:09:53 -0700
Message-Id: <1217275793.23502.35.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Munson <ebmunson@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 12:17 -0700, Eric Munson wrote:
> 
> +static unsigned long personality_page_align(unsigned long addr)
> +{
> +       if (current->personality & HUGETLB_STACK)
> +#ifdef CONFIG_STACK_GROWSUP
> +               return HPAGE_ALIGN(addr);
> +#else
> +               return addr & HPAGE_MASK;
> +#endif
> +
> +       return PAGE_ALIGN(addr);
> +}
...
> -       stack_top = PAGE_ALIGN(stack_top);
> +       stack_top = personality_page_align(stack_top);

Just out of curiosity, why doesn't the existing small-page case seem to
care about the stack growing up/down?  Why do you need to care in the
large page case?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

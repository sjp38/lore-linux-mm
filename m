Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SFp5Lv244684
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:51:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SFp4Mo117172
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 09:51:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SFp4Y7002328
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 09:51:04 -0600
Message-ID: <41811566.2070200@us.ibm.com>
Date: Thu, 28 Oct 2004 08:51:02 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [2/7] 060 refactor setup_memory i386
References: <E1CNBE0-0006bV-ML@ladymac.shadowen.org>
In-Reply-To: <E1CNBE0-0006bV-ML@ladymac.shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> +#ifndef CONFIG_DISCONTIGMEM
> +void __init setup_bootmem_allocator(void);
>  static unsigned long __init setup_memory(void)
>  {
...
> +#endif /* !CONFIG_DISCONTIGMEM */
> +
> +void __init setup_bootmem_allocator(void)
> +{

Won't this double define setup_bootmem_allocator() when 
CONFIG_DISCONTIGMEM is disabled?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

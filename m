Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADDAC6B02A6
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 16:27:39 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6LKNm4Q000412
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:23:48 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6LKRJBk213864
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:27:20 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6LKUbtx026646
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:30:38 -0600
Message-ID: <4C475827.8040605@linux.vnet.ibm.com>
Date: Wed, 21 Jul 2010 15:27:19 -0500
From: Brian King <brking@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] v3 Define memory_block_size_bytes() for ppc/pseries
References: <4C451BF5.50304@austin.ibm.com> <4C451F05.9010502@austin.ibm.com>
In-Reply-To: <4C451F05.9010502@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 07/19/2010 10:59 PM, Nathan Fontenot wrote:
> 
> +static u32 get_memblock_size(void)
> +{
> +	struct device_node *np;
> +	unsigned int memblock_size = 0;
> +
> +	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
> +	if (np) {
> +		const unsigned int *size;

This needs to be an unsigned long, otherwise I always get zero on my p6.

> +
> +		size = of_get_property(np, "ibm,lmb-size", NULL);
> +		memblock_size = size ? *size : 0;
> +
> +		of_node_put(np);



-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

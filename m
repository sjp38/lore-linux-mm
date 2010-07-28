Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 153A56B02AC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:50:19 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6SDiZF5011104
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:44:35 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6SDoEbQ343630
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:50:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6SDoEQu008323
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:50:14 -0300
Message-ID: <4C503594.7040602@linux.vnet.ibm.com>
Date: Wed, 28 Jul 2010 08:50:12 -0500
From: Brian King <brking@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] v3 Update the node sysfs code
References: <4C451BF5.50304@austin.ibm.com> <4C451EAF.1080505@austin.ibm.com>
In-Reply-To: <4C451EAF.1080505@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 07/19/2010 10:57 PM, Nathan Fontenot wrote:
> Index: linux-2.6/include/linux/node.h
> ===================================================================
> --- linux-2.6.orig/include/linux/node.h	2010-07-19 21:10:25.000000000 -0500
> +++ linux-2.6/include/linux/node.h	2010-07-19 21:13:11.000000000 -0500
> @@ -44,7 +44,8 @@ extern int register_cpu_under_node(unsig
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						int nid);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
> +extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +					   unsigned long phys_index);

You also need to update the inline definition of unregister_mem_sect_under_nodes
for the !CONFIG_NUMA case.

-Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

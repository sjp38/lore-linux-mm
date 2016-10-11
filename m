Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D775C6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:17:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so14864584pfz.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:17:39 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id xc5si2564108pab.198.2016.10.11.06.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 06:17:39 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id rw4so1645682pab.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:17:39 -0700 (PDT)
Subject: Re: [PATCH v4 5/5] mm: enable CONFIG_MOVABLE_NODE on non-x86 arches
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-6-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <6d781236-3f2a-8fe6-682f-efa2c01bf429@gmail.com>
Date: Wed, 12 Oct 2016 00:17:31 +1100
MIME-Version: 1.0
In-Reply-To: <1475778995-1420-6-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 07/10/16 05:36, Reza Arbab wrote:
> To support movable memory nodes (CONFIG_MOVABLE_NODE), at least one of
> the following must be true:
> 
> 1. We're on x86. This arch has the capability to identify movable nodes
>    at boot by parsing the ACPI SRAT, if the movable_node option is used.
> 
> 2. Our config supports memory hotplug, which means that a movable node
>    can be created by hotplugging all of its memory into ZONE_MOVABLE.
> 
> Fix the Kconfig definition of CONFIG_MOVABLE_NODE, which currently
> recognizes (1), but not (2).
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  mm/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index be0ee11..5d0818f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -153,7 +153,7 @@ config MOVABLE_NODE
>  	bool "Enable to assign a node which has only movable memory"
>  	depends on HAVE_MEMBLOCK
>  	depends on NO_BOOTMEM
> -	depends on X86_64
> +	depends on X86_64 || MEMORY_HOTPLUG
>  	depends on NUMA
>  	default n
>  	help
> 

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

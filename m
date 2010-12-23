Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 634626B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 19:28:00 -0500 (EST)
Date: Wed, 22 Dec 2010 16:27:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2/7, v9] NUMA Hotplug Emulator: Add numa=possible option
Message-Id: <20101222162717.289cfe01.akpm@linux-foundation.org>
In-Reply-To: <20101210073242.357094158@intel.com>
References: <20101210073119.156388875@intel.com>
	<20101210073242.357094158@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:31:21 +0800
shaohui.zheng@intel.com wrote:

> @@ -646,6 +647,15 @@ void __init initmem_init(unsigned long start_pfn, unsigned long last_pfn,
>  		numa_set_node(i, 0);
>  	memblock_x86_register_active_regions(0, start_pfn, last_pfn);
>  	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn << PAGE_SHIFT);
> +out: __maybe_unused

hm, I didn't know you could do that with labels.

Does it work?

> +	for (i = 0; i < numa_possible_nodes; i++) {
> +		int nid;
> +
> +		nid = first_unset_node(node_possible_map);
> +		if (nid == MAX_NUMNODES)
> +			break;
> +		node_set(nid, node_possible_map);
> +	}
>  }
>  
>  unsigned long __init numa_free_all_bootmem(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1109C6B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 19:29:31 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so23482697pdb.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 16:29:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t12si346607pbs.27.2015.05.06.16.29.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 16:29:30 -0700 (PDT)
Date: Wed, 6 May 2015 16:29:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm/memblock: Add extra "flag" to memblock to allow
 selection of memory based on attribute
Message-Id: <20150506162929.f97cf487bd41686325f9da2f@linux-foundation.org>
In-Reply-To: <ff806a70c38aa2cf02a923a47298d40e54082d11.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
	<ff806a70c38aa2cf02a923a47298d40e54082d11.1430772743.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Apr 2015 11:31:24 -0700 Tony Luck <tony.luck@intel.com> wrote:

> No functional changes
> 
> ...
>
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -61,7 +61,7 @@ extern bool movable_node_enabled;
>  
>  phys_addr_t memblock_find_in_range_node(phys_addr_t size, phys_addr_t align,
>  					    phys_addr_t start, phys_addr_t end,
> -					    int nid);
> +					    int nid, u32 flag);

Sometimes this is called "flag", other times it is called "flags".  Can
we please be consistent?  "flags" seems to be the way to go.

Also, memblock_region.flags has type unsigned long, but you've used
u32.  ulong seems better.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

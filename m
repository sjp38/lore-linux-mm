Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 305336B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:16:29 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id bh4so130632pad.26
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 23:16:28 -0700 (PDT)
Date: Tue, 9 Apr 2013 23:16:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/3] resource: Add release_mem_region_adjustable()
In-Reply-To: <1365440996-30981-3-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.02.1304092315180.3916@chino.kir.corp.google.com>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com> <1365440996-30981-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Mon, 8 Apr 2013, Toshi Kani wrote:

> Added release_mem_region_adjustable(), which releases a requested
> region from a currently busy memory resource.  This interface
> adjusts the matched memory resource accordingly even if the
> requested region does not match exactly but still fits into.
> 
> This new interface is intended for memory hot-delete.  During
> bootup, memory resources are inserted from the boot descriptor
> table, such as EFI Memory Table and e820.  Each memory resource
> entry usually covers the whole contigous memory range.  Memory
> hot-delete request, on the other hand, may target to a particular
> range of memory resource, and its size can be much smaller than
> the whole contiguous memory.  Since the existing release interfaces
> like __release_region() require a requested region to be exactly
> matched to a resource entry, they do not allow a partial resource
> to be released.
> 
> There is no change to the existing interfaces since their restriction
> is valid for I/O resources.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Should this emit a warning for attempting to free a non-existant region 
like __release_region() does?

I think it would be better to base this off my patch and surround it with 
#ifdef CONFIG_MEMORY_HOTREMOVE as suggested by Andrew.  There shouldn't be 
any conflicts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

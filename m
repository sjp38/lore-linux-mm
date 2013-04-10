Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 13B086B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:13:42 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so548485pad.30
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:13:42 -0700 (PDT)
Date: Wed, 10 Apr 2013 15:13:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/3] mm: Change __remove_pages() to call
 release_mem_region_adjustable()
In-Reply-To: <1365614221-685-4-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.02.1304101513260.1526@chino.kir.corp.google.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com> <1365614221-685-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 10 Apr 2013, Toshi Kani wrote:

> Changed __remove_pages() to call release_mem_region_adjustable().
> This allows a requested memory range to be released from
> the iomem_resource table even if it does not match exactly to
> an resource entry but still fits into.  The resource entries
> initialized at bootup usually cover the whole contiguous
> memory ranges and may not necessarily match with the size of
> memory hot-delete requests.
> 
> If release_mem_region_adjustable() failed, __remove_pages() emits
> a warning message and continues to proceed as it was the case
> with release_mem_region().  release_mem_region(), which is defined
> to __release_region(), emits a warning message and returns no error
> since a void function.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by : Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 25F356B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 18:40:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id mc17so1093334pbc.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:40:40 -0700 (PDT)
Date: Thu, 11 Apr 2013 15:40:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] resource: Update config option of
 release_mem_region_adjustable()
In-Reply-To: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.02.1304111540200.31420@chino.kir.corp.google.com>
References: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Thu, 11 Apr 2013, Toshi Kani wrote:

> Changed the config option of release_mem_region_adjustable() from
> CONFIG_MEMORY_HOTPLUG to CONFIG_MEMORY_HOTREMOVE since this function
> is only used for memory hot-delete.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Suggested-by: David Rientjes <rientjes@google.com>
Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

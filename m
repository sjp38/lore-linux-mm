Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 462AB6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 18:43:55 -0400 (EDT)
Message-ID: <1365719494.32127.119.camel@misato.fc.hp.com>
Subject: Re: [PATCH] resource: Update config option of
 release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 11 Apr 2013 16:31:34 -0600
In-Reply-To: <alpine.DEB.2.02.1304111540200.31420@chino.kir.corp.google.com>
References: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.02.1304111540200.31420@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Thu, 2013-04-11 at 15:40 -0700, David Rientjes wrote:
> On Thu, 11 Apr 2013, Toshi Kani wrote:
> 
> > Changed the config option of release_mem_region_adjustable() from
> > CONFIG_MEMORY_HOTPLUG to CONFIG_MEMORY_HOTREMOVE since this function
> > is only used for memory hot-delete.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Acked-by: David Rientjes <rientjes@google.com>

Thanks David!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

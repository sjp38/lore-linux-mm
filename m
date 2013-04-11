Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1700E6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:55:34 -0400 (EDT)
Message-ID: <1365723793.32127.120.camel@misato.fc.hp.com>
Subject: Re: [PATCH] resource: Update config option of
 release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 11 Apr 2013 17:43:13 -0600
In-Reply-To: <51674C30.5060309@jp.fujitsu.com>
References: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
	 <51674C30.5060309@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Fri, 2013-04-12 at 08:50 +0900, Yasuaki Ishimatsu wrote:
> 2013/04/12 7:26, Toshi Kani wrote:
> > Changed the config option of release_mem_region_adjustable() from
> > CONFIG_MEMORY_HOTPLUG to CONFIG_MEMORY_HOTREMOVE since this function
> > is only used for memory hot-delete.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> 
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks Yasuaki!
-Toshi




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

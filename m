Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 7BEF66B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 17:10:42 -0400 (EDT)
Message-ID: <1365454703.32127.8.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 0/3] Support memory hot-delete to boot memory
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 08 Apr 2013 14:58:23 -0600
In-Reply-To: <20130408134438.2a4388a07163e10a37158eed@linux-foundation.org>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com>
	 <20130408134438.2a4388a07163e10a37158eed@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Mon, 2013-04-08 at 13:44 -0700, Andrew Morton wrote:
> On Mon,  8 Apr 2013 11:09:53 -0600 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > Memory hot-delete to a memory range present at boot causes an
> > error message in __release_region(), such as:
> > 
> >  Trying to free nonexistent resource <0000000070000000-0000000077ffffff>
> > 
> > Hot-delete operation still continues since __release_region() is 
> > a void function, but the target memory range is not freed from
> > iomem_resource as the result.  This also leads a failure in a 
> > subsequent hot-add operation to the same memory range since the
> > address range is still in-use in iomem_resource.
> > 
> > This problem happens because the granularity of memory resource ranges
> > may be different between boot and hot-delete.
> 
> So we don't need this new code if CONFIG_MEMORY_HOTPLUG=n?  If so, can
> we please arrange for it to not be present if the user doesn't need it?

Good point!  Yes, since the new function is intended for memory
hot-delete and is only called from __remove_pages() in
mm/memory_hotplug.c, it should be added as #ifdef CONFIG_MEMORY_HOTPLUG
in PATCH 2/3.

I will make the change, and send an updated patch to PATCH 2/3.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

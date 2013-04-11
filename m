Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id BDBCC6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:42:25 -0400 (EDT)
Message-ID: <1365712204.32127.118.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 3/3] mm: Change __remove_pages() to call
 release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 11 Apr 2013 14:30:04 -0600
In-Reply-To: <alpine.DEB.2.02.1304101513260.1526@chino.kir.corp.google.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
	 <1365614221-685-4-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.02.1304101513260.1526@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 2013-04-10 at 15:13 -0700, David Rientjes wrote:
> On Wed, 10 Apr 2013, Toshi Kani wrote:
> 
> > Changed __remove_pages() to call release_mem_region_adjustable().
> > This allows a requested memory range to be released from
> > the iomem_resource table even if it does not match exactly to
> > an resource entry but still fits into.  The resource entries
> > initialized at bootup usually cover the whole contiguous
> > memory ranges and may not necessarily match with the size of
> > memory hot-delete requests.
> > 
> > If release_mem_region_adjustable() failed, __remove_pages() emits
> > a warning message and continues to proceed as it was the case
> > with release_mem_region().  release_mem_region(), which is defined
> > to __release_region(), emits a warning message and returns no error
> > since a void function.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > Reviewed-by : Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks David!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 6C2606B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 09:24:15 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3740578pbb.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2012 06:24:14 -0700 (PDT)
Date: Fri, 17 Aug 2012 06:24:10 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] memory hotplug: avoid double registration on ia64
 platform
Message-ID: <20120817132410.GB28980@kroah.com>
References: <502DF84F.8040708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502DF84F.8040708@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi <qiuxishi@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, tony.luck@intel.com, yinghai@kernel.org, jiang.liu@huawei.com, qiuxishi@huawei.com, bessel.wang@huawei.com, wujianguo@huawei.com, paul.gortmaker@windriver.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, minchan@kernel.org, chenkeping@huawei.com, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, liuj97@gmail.com

On Fri, Aug 17, 2012 at 03:52:47PM +0800, qiuxishi wrote:
> From: Xishi Qiu <qiuxishi@huawei.com>
> 
> Hi all,
> There may be have a bug when register section info. For example, on
> an Itanium platform, the pfn range of node0 includes the other nodes.
> So when hot remove memory, we can't free the memmap's page because
> page_count() is 2 after put_page_bootmem().
> 
> sparse_remove_one_section()->free_section_usemap()->free_map_bootmem()
> ->put_page_bootmem()
> 
> pgdat0: start_pfn=0x100,    spanned_pfn=0x20fb00, present_pfn=0x7f8a3, => 0x100-0x20fc00
> pgdat1: start_pfn=0x80000,  spanned_pfn=0x80000,  present_pfn=0x80000, => 0x80000-0x100000
> pgdat2: start_pfn=0x100000, spanned_pfn=0x80000,  present_pfn=0x80000, => 0x100000-0x180000
> pgdat3: start_pfn=0x180000, spanned_pfn=0x80000,  present_pfn=0x80000, => 0x180000-0x200000
> 
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/memory_hotplug.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

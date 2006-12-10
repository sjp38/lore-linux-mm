Message-ID: <457C0D86.70603@shadowen.org>
Date: Sun, 10 Dec 2006 13:37:10 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>, heiko.carstens@de.ibm.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, this is patches for the virtual mem_map on sparsemem.
> 
> The virtual mem_map will reduce costs of page_to_pfn/pfn_to_page of
> SPARSEMEM_EXTREME.
> 
> I post this series in October but haven't been able to update.
> I rewrote the whole patches and reflected comments from Christoph-san and Andy-san.
> tested on ia64/tiger4.
> 
> Changes v1 -> v2:
> - support memory hotplug case.
> - uses static address for vmem_map (ia64)
> - added optimized pfn_valid() for ia64  (experimental)
> 
> consists of 5 patches:
> 1.. generic vmemmap_sparsemem
> 2.. memory hotplug support
> 3.. ia64 vmemmap_sparsemem definitions
> 4.. optimized pfn_valid  (experimental) 
> 5.. changes for pfn_valid  (experimental)
> 
> I don't manage large-page-size vmem_map in this series to keep patches simple.
> maybe I need more study to implement it in clean way.
> 
> This patch is against 2.6.19-rc6-mm2, and I'll rebase this to the next -mm
> (possibly). So this patch is just for RFC.
> 
> Any comments are welcome.
> -Kame

Sorry, I started reviewing v2 and out comes v3 :).

I have to say that I have generally been a virtual memap sceptic.  It 
seems complex and any testing I have done or seen doesn't seem to show 
any noticible performance benefit.

That said I do like the general thrust of this patch set.  There is 
basically no architecture specific component for this implementation 
other than specifying the base address.  This seems worth of testing 
(and I see akpm has already slurped this up) good.

Would we expect to see this replace the existing ia64 implementation in 
the long term?  I'd hate to see us having competing implementations 
here.  Also Heiko would this framework with your s390 requirements for 
vmem_map, I know that you have a particularly challenging physical 
layout?  It would be great to see just one of these in the kernel.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

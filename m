Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9D5456B0072
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:05:41 -0500 (EST)
Date: Thu, 29 Nov 2012 11:05:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
Message-ID: <20121129110535.GY8218@suse.de>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
 <50B5CFAE.80103@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
 <50B73B22.90500@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50B73B22.90500@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On Thu, Nov 29, 2012 at 07:38:26PM +0900, Yasuaki Ishimatsu wrote:
> Hi Tony,
> 
> 2012/11/29 6:34, Luck, Tony wrote:
> >>1. use firmware information
> >>   According to ACPI spec 5.0, SRAT table has memory affinity structure
> >>   and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
> >>   Affinity Structure". If we use the information, we might be able to
> >>   specify movable memory by firmware. For example, if Hot Pluggable
> >>   Filed is enabled, Linux sets the memory as movable memory.
> >>
> >>2. use boot option
> >>   This is our proposal. New boot option can specify memory range to use
> >>   as movable memory.
> >
> >Isn't this just moving the work to the user? To pick good values for the
> 
> Yes.
> 
> >movable areas, they need to know how the memory lines up across
> >node boundaries ... because they need to make sure to allow some
> >non-movable memory allocations on each node so that the kernel can
> >take advantage of node locality.
> 
> There is no problem.
> Linux has already two boot options, kernelcore= and movablecore=.
> So if we use them, non-movable memory is divided into each node evenly.
> 

The motivation for those options was to reserve a percentage of memory
to be used for hugepage allocation. If hugepages were not being used at
a particular time then they could be used for other purposes. While the
system could in theory face lowmem/highmem style problems, in practice
it did not happen because the memory would be allocated as hugetlbfs
pages and unavailable anyway. The same does not really apply to a general
purpose system that you want to support memory hot-remove on so be wary of
lowmem/highmem style problems caused by relying too heavily on ZONE_MOVABLE.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5EA356B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:59:30 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 5 Feb 2013 17:59:29 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0DE466E801A
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:59:25 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15MxPhc349984
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 17:59:26 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15MxO8o008813
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 15:59:25 -0700
Message-ID: <51118ECB.10006@linux.vnet.ibm.com>
Date: Tue, 05 Feb 2013 14:59:23 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/9] mm: zone & pgdat accessors plus some cleanup
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com> <20130201163924.75edfe40.akpm@linux-foundation.org>
In-Reply-To: <20130201163924.75edfe40.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Jiang Liu <liuj97@gmail.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 02/01/2013 04:39 PM, Andrew Morton wrote:
> On Thu, 17 Jan 2013 14:52:52 -0800
> Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>
>> Summaries:
>> 1 - avoid repeating checks for section in page flags by adding a define.
>> 2 - add & switch to zone_end_pfn() and zone_spans_pfn()
>> 3 - adds zone_is_initialized() & zone_is_empty()
>> 4 - adds a VM_BUG using zone_is_initialized() in __free_one_page()
>> 5 - add pgdat_end_pfn() and pgdat_is_empty()
>> 6 - add debugging message to VM_BUG check.
>> 7 - add ensure_zone_is_initialized() (for memory_hotplug)
>> 8 - use the above addition in memory_hotplug
>> 9 - use pgdat_end_pfn()
>
> Well that's a nice little patchset.
>
> Some of the patches were marked From:cody@linux.vnet.ibm.com and others
> were From:jmesmon@gmail.com.  This is strange.  If you want me to fix
> that up, please let me know which is preferred.

They should all be "From:cody@linux.vnet.ibm.com", other address was me 
messing up gitconfig (which I've since fixed).

>> As a general concern: spanned_pages & start_pfn (in pgdat & zone) are supposed
>> to be locked (via a seqlock) when read (due to changes to them via
>> memory_hotplug), but very few (only 1?) of their users appear to actually lock
>> them.
>
> OK, thanks.  Perhaps this is something which the memory-hotplug
> developers could take a look at?

Yep. It's not immediately clear that not locking on read would do 
terrible things, but at the least the documentation needs fixing and 
explanation as to why the locking is not used some (or all) places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

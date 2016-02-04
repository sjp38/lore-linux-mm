Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 68BE64403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 04:30:30 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l66so107992970wml.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 01:30:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp7si16520727wjb.73.2016.02.04.01.30.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 01:30:29 -0800 (PST)
Subject: Re: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
References: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
 <20160204060221.GA14877@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B31A31.3070406@suse.cz>
Date: Thu, 4 Feb 2016 10:30:25 +0100
MIME-Version: 1.0
In-Reply-To: <20160204060221.GA14877@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/04/2016 07:02 AM, Joonsoo Kim wrote:
> On Wed, Feb 03, 2016 at 06:50:11PM +0100, Vlastimil Babka wrote:
>> Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
>> runtime") has added the runtime gigantic page allocation via
>> alloc_contig_range(), making this support available only when CONFIG_CMA is
>> enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
>> associated infrastructure, it is possible with few simple adjustments to
>> require only CONFIG_MEMORY_ISOLATION instead of full CONFIG_CMA.
>>
>> After this patch, alloc_contig_range() and related functions are available
>> and used for gigantic pages with just CONFIG_MEMORY_ISOLATION enabled. Note
>> CONFIG_CMA selects CONFIG_MEMORY_ISOLATION. This allows supporting runtime
>> gigantic pages without the CMA-specific checks in page allocator fastpaths.
>
> You need to set CONFIG_COMPACTION or CONFIG_CMA to use
> isolate_migratepages_range() and others in alloc_contig_range().

Hm, right, thanks for catching this. I admit I didn't try disabling 
compaction during the tests.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

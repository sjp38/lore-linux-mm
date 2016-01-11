Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A926F828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:56:25 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e65so42657608pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 01:56:25 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ko6si45481938pab.2.2016.01.11.01.56.24
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 01:56:24 -0800 (PST)
Subject: Re: [PATCH v4 2/2] mm/page_alloc.c: introduce kernelcore=mirror
 option
References: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1452241613-19680-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <568FEBAF.9040405@arm.com>
 <20160108151223.a9b7e9099de69dbe6309d159@linux-foundation.org>
From: Sudeep Holla <sudeep.holla@arm.com>
Message-ID: <56937C44.9040707@arm.com>
Date: Mon, 11 Jan 2016 09:56:20 +0000
MIME-Version: 1.0
In-Reply-To: <20160108151223.a9b7e9099de69dbe6309d159@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, arnd@arndb.de, steve.capper@linaro.org



On 08/01/16 23:12, Andrew Morton wrote:
> On Fri, 8 Jan 2016 17:02:39 +0000 Sudeep Holla <sudeep.holla@arm.com> wrote:
>
>>> +
>>> +			/*
>>> +			 * if not mirrored_kernelcore and ZONE_MOVABLE exists,
>>> +			 * range from zone_movable_pfn[nid] to end of each node
>>> +			 * should be ZONE_MOVABLE not ZONE_NORMAL. skip it.
>>> +			 */
>>> +			if (!mirrored_kernelcore && zone_movable_pfn[nid])
>>> +				if (zone == ZONE_NORMAL &&
>>> +				    pfn >= zone_movable_pfn[nid])
>>> +					continue;
>>> +
>>
>> I tried this with today's -next, the above lines gave compilation error.
>> Moved them below into HAVE_MEMBLOCK_NODE_MAP and tested it on ARM64.
>> I don't see the previous backtraces. Let me know if that's correct or
>> you can post a version that compiles correctly and I can give a try.
>
> Thanks.   I'll include the below and shall add your tested-by:, OK?
>

Yes this is the exact change I tested. Also I retested your latest patch
set with today's -next. So,

Tested-by: Sudeep Holla <sudeep.holla@arm.com>

-- 
Regards,
Sudeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

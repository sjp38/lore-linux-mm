Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 362EC6B0253
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:30:22 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id b62so11878813qkh.18
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 10:30:22 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c31si189918qtb.357.2017.11.13.10.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 10:30:21 -0800 (PST)
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
 <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
Date: Mon, 13 Nov 2017 10:30:10 -0800
MIME-Version: 1.0
In-Reply-To: <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/13/2017 10:17 AM, Dave Hansen wrote:
> On 11/13/2017 10:11 AM, Roman Gushchin wrote:
>> On Mon, Nov 13, 2017 at 09:06:32AM -0800, Dave Hansen wrote:
>>> On 11/13/2017 08:03 AM, Roman Gushchin wrote:
>>>> To solve this problem, let's display stats for all hugepage sizes.
>>>> To provide the backward compatibility let's save the existing format
>>>> for the default size, and add a prefix (e.g. 1G_) for non-default sizes.
>>>
>>> Is there something keeping you from using the sysfs version of this
>>> information?
>>
>> Just answered the same question to Michal.
>>
>> In two words: it would be nice to have a high-level overview of
>> memory usage in the system in /proc/meminfo. 
> 
> I don't think it's worth cluttering up meminfo for this, imnho.

I tend to agree that it would be better not to add additional huge page
sizes here.  It may not seem too intrusive to (potentially) add one extra
set of entries for GB huge pages on x86.  However, other architectures
such as powerpc or sparc have several several huge pages sizes that could
potentially be added here as well.  Although, in practice one does tend
to use a single huge pages size.  If you change the default huge page
size, then those entries will be in /proc/meminfo.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

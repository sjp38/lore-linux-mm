Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDD126B0261
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:17:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v2so15473809pfa.10
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 10:17:33 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e13si1235186pgt.664.2017.11.13.10.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 10:17:32 -0800 (PST)
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
Date: Mon, 13 Nov 2017 10:17:30 -0800
MIME-Version: 1.0
In-Reply-To: <20171113181105.GA27034@castle>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/13/2017 10:11 AM, Roman Gushchin wrote:
> On Mon, Nov 13, 2017 at 09:06:32AM -0800, Dave Hansen wrote:
>> On 11/13/2017 08:03 AM, Roman Gushchin wrote:
>>> To solve this problem, let's display stats for all hugepage sizes.
>>> To provide the backward compatibility let's save the existing format
>>> for the default size, and add a prefix (e.g. 1G_) for non-default sizes.
>>
>> Is there something keeping you from using the sysfs version of this
>> information?
> 
> Just answered the same question to Michal.
> 
> In two words: it would be nice to have a high-level overview of
> memory usage in the system in /proc/meminfo. 

I don't think it's worth cluttering up meminfo for this, imnho.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF6636B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:25:33 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id l75so11964228qkh.7
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:25:33 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v186si2102294qkh.7.2017.11.13.11.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 11:25:33 -0800 (PST)
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
 <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
 <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
 <20171113184454.GA18531@castle> <20171113191056.GA28749@cmpxchg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0842738c-1c6f-9a29-b9a6-21e5af898c31@oracle.com>
Date: Mon, 13 Nov 2017 11:25:21 -0800
MIME-Version: 1.0
In-Reply-To: <20171113191056.GA28749@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/13/2017 11:10 AM, Johannes Weiner wrote:
> On Mon, Nov 13, 2017 at 06:45:01PM +0000, Roman Gushchin wrote:
>> Or, at least, some total counter, e.g. how much memory is consumed
>> by hugetlb pages?
> 
> I'm not a big fan of the verbose breakdown for every huge page size.
> As others have pointed out such detail exists elswhere.
> 
> But I do think we should have a summary counter for memory consumed by
> hugetlb that lets you know how much is missing from MemTotal. This can
> be large parts of overall memory, and right now /proc/meminfo will
> give the impression we are leaking those pages.
> 
> Maybe a simple summary counter for everything set aside by the hugetlb
> subsystem - default and non-default page sizes, whether they're used
> or only reserved etc.?
> 
> Hugetlb 12345 kB

I would prefer this approach.  The 'trick' is coming up with a name or
description that is not confusing.  Unfortunately, we have to leave the
existing entries.  So, this new entry will be greater than or equal to
HugePages_Total. :(  I guess Hugetlb is as good of a name as any?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 940A16B0260
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:36:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so75594143wmv.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:36:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d136si17496785wme.95.2017.01.31.06.36.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 06:36:48 -0800 (PST)
Subject: Re: [RFC V2 05/12] cpuset: Add cpuset_inc() inside cpuset_init()
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
 <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8f442e1d-6c4d-990b-74e7-6d9a16c4576f@suse.cz>
Date: Tue, 31 Jan 2017 15:36:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 01/30/2017 09:30 PM, Mel Gorman wrote:
> On Mon, Jan 30, 2017 at 09:05:46AM +0530, Anshuman Khandual wrote:
>> Currently cpusets_enabled() wrongfully returns 0 even if we have a root
>> cpuset configured on the system. This got missed when jump level was
>> introduced in place of number_of_cpusets with the commit 664eeddeef65
>> ("mm: page_alloc: use jump labels to avoid checking number_of_cpusets")
>> . This fixes the problem so that cpusets_enabled() returns positive even
>> for the root cpuset.
>>
>> Fixes: 664eeddeef65 ("mm: page_alloc: use jump labels to avoid")
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> Superficially, this appears to always activate the cpuset_enabled
> branch() when it doesn't really make sense that the root cpuset be
> restricted.

Yes that's why root cpuset doesn't "count", as it's not supposed to be
restricted (it's also documented in cpusets.txt) Thus the "Fixes:" tag
is very misleading.

> I strongly suspect it should be altered to cpuset_inc only
> if the root cpuset is configured to isolate memory.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id F21796B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:46:05 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d15so12775732qtg.2
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:46:05 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x143si1061319qka.285.2018.01.30.18.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 18:46:05 -0800 (PST)
Subject: Re: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
 <20180130075949.GN21609@dhcp22.suse.cz>
 <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <069a5533-2689-6764-2ec5-9ef0a1351860@oracle.com>
Date: Tue, 30 Jan 2018 18:40:58 -0800
MIME-Version: 1.0
In-Reply-To: <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 01/30/2018 06:25 PM, Anshuman Khandual wrote:
> On 01/30/2018 01:29 PM, Michal Hocko wrote:
>> On Tue 30-01-18 08:37:14, Anshuman Khandual wrote:
>>> alloc_contig_range() initiates compaction and eventual migration for
>>> the purpose of either CMA or HugeTLB allocation. At present, reason
>>> code remains the same MR_CMA for either of those cases. Lets add a
>>> new reason code which will differentiate the purpose of migration
>>> as HugeTLB allocation instead.
>> Why do we need it?
> 
> The same reason why we have MR_CMA (maybe some other ones as well) at
> present, for reporting purpose through traces at the least. It just
> seemed like same reason code is being used for two different purpose
> of migration.
> 

I was 'thinking' that we could potentially open up alloc_contig_range()
for more general purpose use.  Users would not call alloc_contig_range
directly, but it would be wrapped in a more user friendly API.  Or,
perhaps it gets modified and becomes something else.  Still just thinking
as part of "how do we provide a more general purpose interface for
allocation of more than MAX_ORDER contiguous pages?".

Not sure that we should be adding to the current alloc_contig_range
interface until we decide it is something which will be useful long term.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE229280271
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 04:20:19 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r188so2817036qke.21
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 01:20:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x22si4490156qtc.143.2018.01.05.01.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 01:20:19 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w059J9jq042950
	for <linux-mm@kvack.org>; Fri, 5 Jan 2018 04:20:18 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fa3ngqda1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 05 Jan 2018 04:20:18 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 5 Jan 2018 09:20:16 -0000
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
 <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
 <20180105091443.GJ2801@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 5 Jan 2018 14:50:04 +0530
MIME-Version: 1.0
In-Reply-To: <20180105091443.GJ2801@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/05/2018 02:44 PM, Michal Hocko wrote:
> On Fri 05-01-18 09:22:22, Anshuman Khandual wrote:
> [...]
>> Hi Michal,
>>
>> After slightly modifying your test case (like fixing the page size for
>> powerpc and just doing simple migration from node 0 to 8 instead of the
>> interleaving), I tried to measure the migration speed with and without
>> the patches on mainline. Its interesting....
>>
>> 					10000 pages | 100000 pages
>> 					--------------------------
>> Mainline				165 ms		1674 ms
>> Mainline + first patch (move_pages)	191 ms		1952 ms
>> Mainline + all three patches		146 ms		1469 ms
>>
>> Though overall it gives performance improvement, some how it slows
>> down migration after the first patch. Will look into this further.
> 
> What are you measuring actually? All pages migrated to the same node?

The mount of time move_pages() system call took to move these many
pages from node 0 to node 8. Yeah they migrated to the same node.

> Do you have any profiles? How stable are the results?

No, are you referring to perf record kind profile ? Results were
repeating.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

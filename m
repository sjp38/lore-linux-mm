Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A73086B037C
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:20:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so71301286pfl.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:20:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i7si2604519pfi.394.2017.06.13.03.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 03:20:07 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DAJDtu071228
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:20:07 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b2a456cvx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:20:06 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Jun 2017 11:20:03 +0100
Subject: Re: [RFC v4 00/20] Speculative page faults
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170609150126.GI21764@dhcp22.suse.cz>
 <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
 <20170609163520.GB9332@dhcp22.suse.cz>
 <84e1698a-c85f-ee10-d367-2c203c6eea73@linux.intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 13 Jun 2017 12:19:57 +0200
MIME-Version: 1.0
In-Reply-To: <84e1698a-c85f-ee10-d367-2c203c6eea73@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <98b890bc-10f7-d049-22a4-fe18c712af8d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 09/06/2017 18:59, Tim Chen wrote:
> On 06/09/2017 09:35 AM, Michal Hocko wrote:
>> On Fri 09-06-17 17:25:51, Laurent Dufour wrote:
>> [...]
>>> Thanks Michal for your feedback.
>>>
>>> I mostly focused on this database workload since this is the one where
>>> we hit the mmap_sem bottleneck when running on big node. On my usual
>>> victim node, I checked for basic usage like kernel build time, but I
>>> agree that's clearly not enough.
>>>
>>> I try to find details about the 'kbench' you mentioned, but I didn't get
>>> any valid entry.
>>> Would you please point me on this or any other bench tool you think will
>>> be useful here ?
>>
>> Sorry I meant kernbech (aka parallel kernel build). Other highly threaded
>> workloads doing a lot of page faults and address space modification
>> would be good to see as well. I wish I could give you much more
>> comprehensive list but I am not very good at benchmarks.
>>
> 
> Laurent,
> 
> Have you tried running the multi-fault microbenchmark by Kamezawa?
> It does threaded page faults in parallel.
> Peter ran that when he posted his specualtive page faults patches.
> https://lkml.org/lkml/2010/1/6/28


Thanks Tim to remind me about this, I downloaded and built it a time ago
and forget about it. I'll give it another try !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

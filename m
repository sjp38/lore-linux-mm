Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F03036B0365
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:59:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v104so28643036wrb.6
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:59:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 68si10603641wmv.29.2017.06.13.02.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 02:58:59 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D9wmLM098677
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:58:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b1x82tm4d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:58:57 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Jun 2017 10:58:56 +0100
Subject: Re: [RFC v4 00/20] Speculative page faults
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170609150126.GI21764@dhcp22.suse.cz>
 <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
 <20170609163520.GB9332@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 13 Jun 2017 11:58:50 +0200
MIME-Version: 1.0
In-Reply-To: <20170609163520.GB9332@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <04119fc4-2e7c-a56d-db4c-23860e6cc9a0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 09/06/2017 18:35, Michal Hocko wrote:
> On Fri 09-06-17 17:25:51, Laurent Dufour wrote:
> [...]
>> Thanks Michal for your feedback.
>>
>> I mostly focused on this database workload since this is the one where
>> we hit the mmap_sem bottleneck when running on big node. On my usual
>> victim node, I checked for basic usage like kernel build time, but I
>> agree that's clearly not enough.
>>
>> I try to find details about the 'kbench' you mentioned, but I didn't get
>> any valid entry.
>> Would you please point me on this or any other bench tool you think will
>> be useful here ?
> 
> Sorry I meant kernbech (aka parallel kernel build). Other highly threaded
> workloads doing a lot of page faults and address space modification
> would be good to see as well. I wish I could give you much more
> comprehensive list but I am not very good at benchmarks.
> 

Thanks Michal, I found kernbench 0.5, I will give it a try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

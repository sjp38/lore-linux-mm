Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40EF86B78FB
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:32:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l191-v6so12615490oig.23
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:32:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g3-v6si3317572oia.21.2018.09.06.06.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:32:25 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86DURwU070306
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 09:32:25 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mb4suh90b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:32:24 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 6 Sep 2018 07:32:24 -0600
Subject: Re: [RFC PATCH V2 1/4] mm: Export alloc_migrate_huge_page
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
 <20180906123111.GC26069@dhcp22.suse.cz>
 <20180906123539.GV14951@dhcp22.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 6 Sep 2018 19:02:16 +0530
MIME-Version: 1.0
In-Reply-To: <20180906123539.GV14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <50682adc-5be9-1fac-fd84-abc6bbea7549@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 09/06/2018 06:05 PM, Michal Hocko wrote:
> On Thu 06-09-18 14:31:11, Michal Hocko wrote:
>> On Thu 06-09-18 11:13:39, Aneesh Kumar K.V wrote:
>>> We want to use this to support customized huge page migration.
>>
>> Please be much more specific. Ideally including the user. Btw. why do
>> you want to skip the hugetlb pools? In other words alloc_huge_page_node*
>> which are intended to an external use?
> 
> Ups, I have now found http://lkml.kernel.org/r/20180906054342.25094-2-aneesh.kumar@linux.ibm.com
> which ended up in a different email folder so I have missed it. It would
> be much better to merge those two to make the user immediately obvious.
> There is a good reason to keep newly added functions closer to their
> users.
> 

It is the same series. I will fold the patch 1 and 2.

-aneesh

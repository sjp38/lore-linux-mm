Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83DE16B04D9
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:45:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g14so143633899pgu.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:45:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a61si11031632pla.145.2017.07.11.02.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 02:45:26 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6B9ippD025963
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:45:26 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bmbyy0myu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:45:25 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 11 Jul 2017 19:45:21 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6B9jAkt12714096
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:45:18 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6B9ijbh031317
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:44:46 +1000
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 11 Jul 2017 15:14:27 +0530
MIME-Version: 1.0
In-Reply-To: <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <210533b7-3b29-b6bd-24db-03e0c756a882@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 11:56 AM, Vlastimil Babka wrote:
> On 07/11/2017 08:03 AM, Michal Hocko wrote:
>> On Tue 11-07-17 09:58:42, Anshuman Khandual wrote:
>>>> here. This is hardly something that would save many cycles in a
>>>> relatively cold path.
>>> Though I have not done any detailed instruction level measurement,
>>> there is a reduction in real and system amount of time to execute
>>> the test with and without the patch.
>>>
>>> Without the patch
>>>
>>> real	0m2.100s
>>> user	0m0.162s
>>> sys	0m1.937s
>>>
>>> With this patch
>>>
>>> real	0m0.928s
>>> user	0m0.161s
>>> sys	0m0.756s
>> Are you telling me that two if conditions cause more than a second
>> difference? That sounds suspicious.
> It's removing also a call to get_unmapped_area(), AFAICS. That means a
> vma search?

I believe removing this function is responsible for the
increase in speed of the test execution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

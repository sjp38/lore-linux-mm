Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7549A6B04E3
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:07:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so30920196wrb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:07:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c47si10249336wrc.110.2017.07.11.04.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 04:07:01 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6BB4dKn125748
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:07:00 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bmv0bbga9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:06:59 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 11 Jul 2017 21:06:57 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6BB6rIA22872192
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 21:06:53 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6BB6qH3005451
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 21:06:53 +1000
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 11 Jul 2017 16:36:40 +0530
MIME-Version: 1.0
In-Reply-To: <20170711065030.GE24852@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <fd44dd42-eeb0-0b2e-cb67-787e629c7e2d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 12:20 PM, Michal Hocko wrote:
> On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
>> On 07/11/2017 08:03 AM, Michal Hocko wrote:
>>> On Tue 11-07-17 09:58:42, Anshuman Khandual wrote:
>>>>> here. This is hardly something that would save many cycles in a
>>>>> relatively cold path.
>>>> Though I have not done any detailed instruction level measurement,
>>>> there is a reduction in real and system amount of time to execute
>>>> the test with and without the patch.
>>>>
>>>> Without the patch
>>>>
>>>> real	0m2.100s
>>>> user	0m0.162s
>>>> sys	0m1.937s
>>>>
>>>> With this patch
>>>>
>>>> real	0m0.928s
>>>> user	0m0.161s
>>>> sys	0m0.756s
>>> Are you telling me that two if conditions cause more than a second
>>> difference? That sounds suspicious.
>> It's removing also a call to get_unmapped_area(), AFAICS. That means a
>> vma search?
> Ohh, right. I have somehow missed that. Is this removal intentional? The
> changelog is silent about it.

Yeah it was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

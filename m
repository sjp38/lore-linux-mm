Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC126B04EB
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:19:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u30so30947187wrc.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:19:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u9si8829572wme.191.2017.07.11.04.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 04:19:17 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6BBESiB130937
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:19:16 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bma0phphu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:19:15 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 11 Jul 2017 21:19:13 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6BBJB2r23068766
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 21:19:11 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6BBJ2ex019389
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 21:19:02 +1000
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
 <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
 <20170711071612.GG24852@dhcp22.suse.cz>
 <20170711072223.GH24852@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 11 Jul 2017 16:49:03 +0530
MIME-Version: 1.0
In-Reply-To: <20170711072223.GH24852@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <0fbc7a4a-9e3f-fb64-65cd-3259335bd07e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 12:52 PM, Michal Hocko wrote:
> On Tue 11-07-17 09:16:12, Michal Hocko wrote:
>> On Tue 11-07-17 08:56:04, Vlastimil Babka wrote:
> [...]
>>> It doesn't explain why it's redundant, indeed. Unfortunately, the commit
>>> f106af4e90ea ("fix checks for expand-in-place mremap") which added this,
>>> also doesn't explain why it's needed.
>>
>> Because it doesn't do anything AFAICS.
> 
> Well, it does actually. I have missed security_mmap_addr hook.

But we any way call get_unmapped_area() down the line in the function,
it should be covered then. Does the proposed change look good and be
considered, or any changes required or can be dropped ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

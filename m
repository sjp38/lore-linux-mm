Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32ED944084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 22:15:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u5so134569110pgq.14
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:15:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d23si3398492pli.126.2017.07.10.19.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 19:15:41 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6B2DjqN005489
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 22:15:40 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bmc3g32cg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 22:15:40 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 11 Jul 2017 12:15:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6B2FaJ816973830
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:15:36 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6B2FRub022410
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:15:27 +1000
Subject: Re: [PATCH] mm/mremap: Document MREMAP_FIXED dependency on
 MREMAP_MAYMOVE
References: <20170710113211.31394-1-khandual@linux.vnet.ibm.com>
 <20170710134130.GA19645@dhcp22.suse.cz>
 <40c61daf-da2c-bab9-99d0-a7d7147f4514@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 11 Jul 2017 07:45:32 +0530
MIME-Version: 1.0
In-Reply-To: <40c61daf-da2c-bab9-99d0-a7d7147f4514@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d482a336-cc08-a47e-24b8-8d91316f1d0d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 07/10/2017 11:01 PM, Mike Kravetz wrote:
> On 07/10/2017 06:41 AM, Michal Hocko wrote:
>> On Mon 10-07-17 17:02:11, Anshuman Khandual wrote:
>>> In the header file, just specify the dependency of MREMAP_FIXED
>>> on MREMAP_MAYMOVE and make it explicit for the user space.
>> I really fail to see a point of this patch. The depency belongs to the
>> code and it seems that we already enforce it
>> 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
>> 		return ret;
>>
>> So what is the point here?
> Agree, I am not sure of your reasoning.
> 
> If to assist the programmer, there is no need as this is clearly specified
> in the man page:
> 
> "If  MREMAP_FIXED  is  specified,  then MREMAP_MAYMOVE must also be
>  specified."

Yeah the idea was to assist the programmer and I missed the man page's
details on this. My bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

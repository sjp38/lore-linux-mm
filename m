Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE6386B000A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 11:53:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id m91so11393878otc.17
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 08:53:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e31si3764756otd.314.2018.10.31.08.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 08:53:02 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9VFoIT8065260
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 11:53:01 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nfeumj04k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 11:53:01 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.bm.com>;
	Wed, 31 Oct 2018 15:53:00 -0000
Subject: Re: Memory hotplug vmem pages
References: <17182cdc-cffe-ca39-f5c0-d1c5bd7ec4cb@linux.ibm.com>
 <20181030134433.GE32673@dhcp22.suse.cz>
From: Zaslonko Mikhail <zaslonko@linux.bm.com>
Date: Wed, 31 Oct 2018 16:52:57 +0100
MIME-Version: 1.0
In-Reply-To: <20181030134433.GE32673@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <8c13868c-8fa2-01e8-9940-767be087256f@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Zaslonko Mikhail <zaslonko@linux.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, schwidefsky@de.ibm.com

Hello Michal,

Thanks for your response and for the link. I'm gonna play around with that patchset.

Thanks,
Mikhail Zaslonko

On 30.10.2018 14:44, Michal Hocko wrote:
> [Sorry for late response]
> 
> On Fri 12-10-18 10:15:26, Zaslonko Mikhail wrote:
>> Hello Michal,
>>
>> I've read a recent discussion about introducing the memory types for memory
>> hotplug:
>> https://marc.info/?t=153814716600004&r=1&w=2
>>
>> In particular I was interested in the idea of moving vmem struct pages to
>> the hotplugable memory itself. I'm also looking into it for s390 right now.
>> So, in one of your replies you mentioned that you "have proposed (but
>> haven't finished this due to other stuff) a solution for this". Have you
>> covered any part of that solution yet? Could you please point me to any
>> relevant discussions on this matter?
> 
> the patchset has been posted here [1]. I didn't get around to fix the
> hotremove case when you have to be extra carefule to not remove pfn
> range that backs struct pages still in use. I didn't have problems for
> small systems but 2GB memblocks just crashed.
> 
> [1] http://lkml.kernel.org/r/20170801124111.28881-1-mhocko@kernel.org
> 

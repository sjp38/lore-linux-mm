Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFADD6B04C0
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 04:44:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 40so3891236wrv.4
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 01:44:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 140si34418wmy.105.2017.09.05.01.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 01:44:48 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v858dUnE040671
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 04:44:47 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2csq86nd7c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 04:44:46 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 18:44:44 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v858igQd24510544
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 18:44:42 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v858igYw022538
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 18:44:42 +1000
Subject: Re: [PATCH] mm, sparse: fix typo in online_mem_sections
References: <20170904112210.3401-1-mhocko@kernel.org>
 <4d648f70-325d-3f60-8620-94c232b380d8@linux.vnet.ibm.com>
 <20170905072836.i4dxrukevojty4ub@dhcp22.suse.cz>
 <20170905073730.4reirga47o4athse@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 14:14:38 +0530
MIME-Version: 1.0
In-Reply-To: <20170905073730.4reirga47o4athse@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d687658d-088c-f1c7-77f9-d0b5845e24c5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 09/05/2017 01:07 PM, Michal Hocko wrote:
> On Tue 05-09-17 09:28:36, Michal Hocko wrote:
>> On Tue 05-09-17 12:32:28, Anshuman Khandual wrote:
>>> On 09/04/2017 04:52 PM, Michal Hocko wrote:
>>>> From: Michal Hocko <mhocko@suse.com>
>>>>
>>>> online_mem_sections accidentally marks online only the first section in
>>>> the given range. This is a typo which hasn't been noticed because I
>>>> haven't tested large 2GB blocks previously. All users of
>>>
>>> Section sizes are normally less than 2GB. Could you please elaborate
>>> why this never got noticed before ?
>>
>> Section size is 128MB which is the default block size as well. So we
>> have one section per block. But if the amount of memory is very large
>> (64GB - see probe_memory_block_size) then we have a 2GB memory blocks
>> so multiple sections per block.
> 
> And just to clarify. Not that 64G would be too large but the original
> patch has been merged in 4.13 so nobody probably managed to hit that
> _yet_.

Got it. Section size is 16MB and block size is 256MB on most of the
POWER platforms. Hence this could have affected them as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

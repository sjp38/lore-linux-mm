Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 447B46B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:23:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x125so116287239pgb.5
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 08:23:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u19si4075404plj.273.2017.03.28.08.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 08:23:09 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2SFE2Q0023888
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:23:08 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29ft6f8wwv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:23:08 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 28 Mar 2017 11:23:07 -0400
Subject: Re: [PATCH V5 16/17] mm: Let arch choose the initial value of task
 size
References: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <87vaqtabw8.fsf@concordia.ellerman.id.au>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 28 Mar 2017 20:52:58 +0530
MIME-Version: 1.0
In-Reply-To: <87vaqtabw8.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <6c8904b5-c4a0-b828-6aad-14220efc5236@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>



On Tuesday 28 March 2017 04:47 PM, Michael Ellerman wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>
>> As we start supporting larger address space (>128TB), we want to give
>> architecture a control on max task size of an application which is different
>> from the TASK_SIZE. For ex: ppc64 needs to track the base page size of a segment
>> and it is copied from mm_context_t to PACA on each context switch. If we know that
>> application has not used an address range above 128TB we only need to copy
>> details about 128TB range to PACA. This will help in improving context switch
>> performance by avoiding larger copy operation.
>>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: linux-mm@kvack.org
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  fs/exec.c | 10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> I'll need an ACK at least on this from someone in mm land.
>
> I assume there's no way I can merge patch 17 without this?

That is correct.

I didn't add linux-mm to cc for rest of the patches. They are all ppc64 
specific and can be found at

https://lists.ozlabs.org/pipermail/linuxppc-dev/2017-March/155726.html


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

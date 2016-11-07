Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECAA96B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 15:28:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so56044148pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 12:28:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f1si32931772pge.132.2016.11.07.12.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 12:21:03 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7KIvxn111394
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 15:21:03 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26jv0dnr5c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:21:02 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 20:21:00 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9955217D8066
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 20:23:18 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA7KKwBV24445132
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 20:20:58 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA7KKv52024360
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 13:20:58 -0700
Subject: Re: [RFC v2 6/7] mm/powerpc: Use generic VDSO remap and unmap
 functions
References: <20161101171101.24704-1-cov@codeaurora.org>
 <20161101171101.24704-6-cov@codeaurora.org>
 <87oa1vn8lc.fsf@concordia.ellerman.id.au>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 7 Nov 2016 21:20:56 +0100
MIME-Version: 1.0
In-Reply-To: <87oa1vn8lc.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e974b3a6-2a80-a416-7583-4b0644e8a613@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Christopher Covington <cov@codeaurora.org>, criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On 04/11/2016 05:59, Michael Ellerman wrote:
> Christopher Covington <cov@codeaurora.org> writes:
> 
>> The PowerPC VDSO remap and unmap code was copied to a generic location,
>> only modifying the variable name expected in mm->context (vdso instead of
>> vdso_base) to match most other architectures. Having adopted this generic
>> naming, drop the code in arch/powerpc and use the generic version.
>>
>> Signed-off-by: Christopher Covington <cov@codeaurora.org>
>> ---
>>  arch/powerpc/Kconfig                     |  1 +
>>  arch/powerpc/include/asm/Kbuild          |  1 +
>>  arch/powerpc/include/asm/mm-arch-hooks.h | 28 -------------------------
>>  arch/powerpc/include/asm/mmu_context.h   | 35 +-------------------------------
>>  4 files changed, 3 insertions(+), 62 deletions(-)
>>  delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
> 
> This looks OK.
> 
> Have you tested it on powerpc? I could but I don't know how to actually
> trigger these paths, I assume I need a CRIU setup?

FWIW, tested on ppc64le using a sample test process moving its VDSO and
then catching a signal on 4.9-rc4 and using CRIU on top of 4.8 with
sightly changes to due minor upstream changes.

Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Tested-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

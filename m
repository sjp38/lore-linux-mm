Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0466B04C8
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 11:54:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 187so4360596wmn.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 08:54:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x14si522817wme.136.2017.09.05.08.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 08:54:36 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v85FsGxO066986
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 11:54:35 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2csvy9pncp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 11:54:34 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 16:54:32 +0100
Subject: Re: [PATCH] mm: Fix mem_cgroup_oom_disable() call missing
References: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170905154650.c3xiwp52btcckjr4@node.shutemov.name>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 17:54:29 +0200
MIME-Version: 1.0
In-Reply-To: <20170905154650.c3xiwp52btcckjr4@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <73199b41-da7d-2bd5-6214-da55ab62cea9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/09/2017 17:46, Kirill A. Shutemov wrote:
> On Tue, Sep 05, 2017 at 05:30:39PM +0200, Laurent Dufour wrote:
>> Seen while reading the code, in handle_mm_fault(), in the case
>> arch_vma_access_permitted() is failing the call to mem_cgroup_oom_disable()
>> is not made.
>>
>> To fix that, move the call to mem_cgroup_oom_enable() after calling
>> arch_vma_access_permitted() as it should not have entered the memcg OOM.
>>
>> Fixes: bae473a423f6 ("mm: introduce fault_env")
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> 
> Ouch. Sorry for this.
> 
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> 
> Cc: stable@ is needed too.

Andrew, should I resent it with stable in copy ?

> 
> It's strange we haven't seen reports of warning from
> mem_cgroup_oom_enable().

AFAIU, arch_vma_access_permitted() is only defined for x86 and it is
failing only in the case of the protection key mismatch, not so much used
for now...

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

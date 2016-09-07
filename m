Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E68F6B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 00:00:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x24so10420470pfa.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 21:00:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j3si8433993pan.276.2016.09.06.21.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 21:00:32 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u873w4ck074492
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 00:00:32 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25a57kc5jm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Sep 2016 00:00:32 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 7 Sep 2016 14:00:29 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 387E82BB0059
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 14:00:11 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8740Bic6750470
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 14:00:11 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8740Al5006791
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 14:00:10 +1000
Date: Wed, 07 Sep 2016 09:30:08 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473140072-24137-2-git-send-email-khandual@linux.vnet.ibm.com> <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <57CF28C5.3090006@intel.com> <CAGXu5jK_sKa2dcVrwhXdp=ZA=ACEY6vmd-LDoy8KmMtCn_aDzw@mail.gmail.com>
In-Reply-To: <CAGXu5jK_sKa2dcVrwhXdp=ZA=ACEY6vmd-LDoy8KmMtCn_aDzw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <57CF90C8.6050409@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 09/07/2016 08:38 AM, Kees Cook wrote:
> On Tue, Sep 6, 2016 at 1:36 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>> On 09/06/2016 01:31 AM, Anshuman Khandual wrote:
>>> [NODE (0)]
>>>         ZONELIST_FALLBACK
>>>         (0) (node 0) (zone DMA c00000000140c000)
>>>         (1) (node 1) (zone DMA c000000100000000)
>>>         (2) (node 2) (zone DMA c000000200000000)
>>>         (3) (node 3) (zone DMA c000000300000000)
>>>         ZONELIST_NOFALLBACK
>>>         (0) (node 0) (zone DMA c00000000140c000)
>>
>> Don't we have some prohibition on dumping out kernel addresses like this
>> so that attackers can't trivially defeat kernel layout randomization?
> 
> Anything printing memory addresses should be using %pK (not %lx as done here).

Learned about the significance of %pK coupled with kptr_restrict
interface. Will change this. Thanks for pointing out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

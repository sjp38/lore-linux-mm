Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B064528026B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 21:37:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so415951670pfj.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:37:22 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id cm7si27188807pad.48.2016.09.26.18.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 18:37:21 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id j3so1451426paj.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:37:21 -0700 (PDT)
Subject: Re: [RFC PATCH] powerpc/mm: THP page cache support
References: <1474560160-7327-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20160926105054.GA16074@node.shutemov.name>
 <87wphy8xny.fsf@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <f0052929-753d-49f7-80e1-85a1f1b237ee@gmail.com>
Date: Tue, 27 Sep 2016 11:37:13 +1000
MIME-Version: 1.0
In-Reply-To: <87wphy8xny.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



On 27/09/16 01:53, Aneesh Kumar K.V wrote:
>>>  
>>> +void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
>>
>> static?
> 
> Ok I will fix that.

inline as well?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

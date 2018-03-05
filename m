Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFABA6B025F
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:38:34 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p11so15084991qtg.19
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:38:34 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 36si1966604qky.256.2018.03.05.12.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 12:38:34 -0800 (PST)
Subject: Re: [PATCH v12 08/11] mm: Clear arch specific VM flags on protection
 change
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
 <df5344a2-f28d-7828-b76b-107dc24be2dd@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <fd08210e-a6af-c3f5-3807-9ffe9dad66b0@oracle.com>
Date: Mon, 5 Mar 2018 13:38:02 -0700
MIME-Version: 1.0
In-Reply-To: <df5344a2-f28d-7828-b76b-107dc24be2dd@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org, davem@davemloft.net
Cc: mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, willy@infradead.org, hughd@google.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, jglisse@redhat.com, dave.jiang@intel.com, dan.j.williams@intel.com, anthony.yznaga@oracle.com, nadav.amit@gmail.com, zi.yan@cs.rutgers.edu, aarcange@redhat.com, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, henry.willard@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:23 PM, Dave Hansen wrote:
> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>> +/* Arch-specific flags to clear when updating VM flags on protection change */
>> +#ifndef VM_ARCH_CLEAR
>> +# define VM_ARCH_CLEAR	VM_NONE
>> +#endif
>> +#define VM_FLAGS_CLEAR	(ARCH_VM_PKEY_FLAGS | VM_ARCH_CLEAR)
> 
> Shouldn't this be defining
> 
> # define VM_ARCH_CLEAR	ARCH_VM_PKEY_FLAGS
> 
> on x86?

ARCH_VM_PKEY_FLAGS is used by x86 as well as powerpc. On those two 
architectures VM_FLAGS_CLEAR will end up being ARCH_VM_PKEY_FLAGS and 
thus current behavior will be retained. Defining VM_ARCH_CLEAR to be 
ARCH_VM_PKEY_FLAGS on x86 will just result in VM_FLAGS_CLEAR to be 
(ARCH_VM_PKEY_FLAGS | ARCH_VM_PKEY_FLAGS) which is superfluous.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

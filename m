Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 158702802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 10:12:36 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id x85so3680476vkx.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 07:12:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 30si1700108uaz.390.2017.09.06.07.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 07:12:34 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <20170904162530.GA21781@amd>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <6494b4c4-6d5b-7e45-f053-00535bb898aa@oracle.com>
Date: Wed, 6 Sep 2017 08:10:05 -0600
MIME-Version: 1.0
In-Reply-To: <20170904162530.GA21781@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 09/04/2017 10:25 AM, Pavel Machek wrote:
> Hi!
> 
>> ADI is a new feature supported on SPARC M7 and newer processors to allow
>> hardware to catch rogue accesses to memory. ADI is supported for data
>> fetches only and not instruction fetches. An app can enable ADI on its
>> data pages, set version tags on them and use versioned addresses to
>> access the data pages. Upper bits of the address contain the version
>> tag. On M7 processors, upper four bits (bits 63-60) contain the version
>> tag. If a rogue app attempts to access ADI enabled data pages, its
>> access is blocked and processor generates an exception. Please see
>> Documentation/sparc/adi.txt for further details.
> 
> I'm afraid I still don't understand what this is meant to prevent.
> 
> IOMMU ignores these, so this is not to prevent rogue DMA from doing
> bad stuff.
> 
> Will gcc be able to compile code that uses these automatically? That
> does not sound easy to me. Can libc automatically use this in malloc()
> to prevent accessing freed data when buffers are overrun?
> 
> Is this for benefit of JITs?
> 

David explained it well. Yes, preventing buffer overflow is one of the 
uses of ADI. Protecting critical data from wild writes caused by 
programming errors is another use. ADI can be used for debugging as well 
during development.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

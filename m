Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D60C6B000A
	for <linux-mm@kvack.org>; Sat,  5 May 2018 00:42:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j6-v6so14856692pgn.7
        for <linux-mm@kvack.org>; Fri, 04 May 2018 21:42:42 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q1-v6si14585884pga.417.2018.05.04.21.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 21:42:41 -0700 (PDT)
Subject: Re: [PATCH v13 3/3] mm, powerpc, x86: introduce an additional vma bit
 for powerpc pkey
References: <1525471183-21277-1-git-send-email-linuxram@us.ibm.com>
 <1525471183-21277-3-git-send-email-linuxram@us.ibm.com>
 <1e37895e-5a18-11c1-58f1-834f96dfd4d5@intel.com>
 <20180505011243.GB5617@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7d1de723-f001-ebbe-6026-91bef88c566d@intel.com>
Date: Fri, 4 May 2018 21:42:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180505011243.GB5617@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de

On 05/04/2018 06:12 PM, Ram Pai wrote:
>> That new line boils down to:
>>
>> 		[ilog2(0)]	= "",
>>
>> on x86.  It wasn't *obvious* to me that it is OK to do that.  The other
>> possibly undefined bits (VM_SOFTDIRTY for instance) #ifdef themselves
>> out of this array.
>>
>> I would just be a wee bit worried that this would overwrite the 0 entry
>> ("??") with "".
> Yes it would :-( and could potentially break anything that depends on
> 0th entry being "??"
> 
> Is the following fix acceptable?
> 
> #if VM_PKEY_BIT4
>                 [ilog2(VM_PKEY_BIT4)]   = "",
> #endif

Yep, I think that works for me.

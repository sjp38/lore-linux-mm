Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF356B0026
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 16:55:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s8so1999899pgf.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:55:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v18si3305524pfa.390.2018.03.28.13.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 13:55:37 -0700 (PDT)
Subject: Re: [PATCH v12 07/22] selftests/vm: fixed bugs in
 pkey_disable_clear()
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-8-git-send-email-linuxram@us.ibm.com>
 <dc5ee0c8-afe3-78aa-001d-7b49b398337b@intel.com>
 <87muys3p2v.fsf@morokweng.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <34fd1ae9-9697-ac6c-d6bc-7c25b4515a25@intel.com>
Date: Wed, 28 Mar 2018 13:55:33 -0700
MIME-Version: 1.0
In-Reply-To: <87muys3p2v.fsf@morokweng.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, ebiederm@xmission.com, arnd@arndb.de

On 03/28/2018 01:47 PM, Thiago Jung Bauermann wrote:
>>>  	if (flags)
>>> -		assert(rdpkey_reg() > orig_pkey_reg);
>>> +		assert(rdpkey_reg() < orig_pkey_reg);
>>>  }
>>>
>>>  void pkey_write_allow(int pkey)
>> This seems so horribly wrong that I wonder how it worked in the first
>> place.  Any idea?
> The code simply wasn't used. pkey_disable_clear() is called by
> pkey_write_allow() and pkey_access_allow(), but before this patch series
> nothing called either of these functions.
> 

Ahh, that explains it.  Can that get stuck in the changelog, please?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 546796B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:34:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 62-v6so6266121ply.4
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:34:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r9si5702866pgf.217.2018.03.16.15.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:34:04 -0700 (PDT)
Subject: Re: [PATCH v12 21/22] selftests/vm: sub-page allocator
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-22-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f2c8f721-b107-3bdc-3c09-01b9849c4ce2@intel.com>
Date: Fri, 16 Mar 2018 15:33:56 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-22-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
...
> @@ -888,6 +917,7 @@ void setup_hugetlbfs(void)
>  void *(*pkey_malloc[])(long size, int prot, u16 pkey) = {
>  
>  	malloc_pkey_with_mprotect,
> +	malloc_pkey_with_mprotect_subpage,
>  	malloc_pkey_anon_huge,
>  	malloc_pkey_hugetlb
>  /* can not do direct with the pkey_mprotect() API:


I think I'd rather have an #ifdef on the array entries than have the
malloc entry do nothing on x86.  Maybe have a ppc-specific section at
the end?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 104A36B000A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:23:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j8so5869350pfh.13
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:23:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 7-v6si7019421ple.604.2018.03.16.15.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:23:44 -0700 (PDT)
Subject: Re: [PATCH v12 13/22] selftests/vm: powerpc implementation for
 generic abstraction
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-14-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5e27e966-d1b9-e56d-45cd-43524fd4448c@intel.com>
Date: Fri, 16 Mar 2018 15:23:28 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-14-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
>  static inline u32 pkey_to_shift(int pkey)
>  {
> +#if defined(__i386__) || defined(__x86_64__) /* arch */
>  	return pkey * PKEY_BITS_PER_PKEY;
> +#elif __powerpc64__ /* arch */
> +	return (NR_PKEYS - pkey - 1) * PKEY_BITS_PER_PKEY;
> +#endif /* arch */
>  }

I really detest the #if #else style.  Can't we just have a pkey_ppc.h
and a pkey_x86.h or something?

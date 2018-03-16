Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B63CF6B002A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:58:25 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m6-v6so6017581pln.8
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:58:25 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e12si5714291pgu.155.2018.03.16.14.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:58:24 -0700 (PDT)
Subject: Re: [PATCH v12 04/22] selftests/vm: typecast the pkey register
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-5-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <00081300-e891-3381-3acd-e3312e54fb58@intel.com>
Date: Fri, 16 Mar 2018 14:58:16 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-5-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> -static inline unsigned int _rdpkey_reg(int line)
> +static inline pkey_reg_t _rdpkey_reg(int line)
>  {
> -	unsigned int pkey_reg = __rdpkey_reg();
> +	pkey_reg_t pkey_reg = __rdpkey_reg();
>  
> -	dprintf4("rdpkey_reg(line=%d) pkey_reg: %x shadow: %x\n",
> +	dprintf4("rdpkey_reg(line=%d) pkey_reg: %016lx shadow: %016lx\n",
>  			line, pkey_reg, shadow_pkey_reg);
>  	assert(pkey_reg == shadow_pkey_reg);

Hmm.  So we're using %lx for an int?  Doesn't the compiler complain
about this?

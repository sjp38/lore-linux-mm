Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C425F6B000E
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:08:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so2737699pgv.12
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:08:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bj11-v6si2834406plb.525.2018.03.16.15.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:08:29 -0700 (PDT)
Subject: Re: [PATCH v12 07/22] selftests/vm: fixed bugs in
 pkey_disable_clear()
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-8-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <dc5ee0c8-afe3-78aa-001d-7b49b398337b@intel.com>
Date: Fri, 16 Mar 2018 15:08:20 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-8-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -461,7 +461,7 @@ void pkey_disable_clear(int pkey, int flags)
>  			pkey, pkey, pkey_rights);
>  	pkey_assert(pkey_rights >= 0);
>  
> -	pkey_rights |= flags;
> +	pkey_rights &= ~flags;
>  
>  	ret = pkey_set(pkey, pkey_rights, 0);
>  	/* pkey_reg and flags have the same format */
> @@ -475,7 +475,7 @@ void pkey_disable_clear(int pkey, int flags)
>  	dprintf1("%s(%d) pkey_reg: 0x%016lx\n", __func__,
>  			pkey, rdpkey_reg());
>  	if (flags)
> -		assert(rdpkey_reg() > orig_pkey_reg);
> +		assert(rdpkey_reg() < orig_pkey_reg);
>  }
>  
>  void pkey_write_allow(int pkey)

This seems so horribly wrong that I wonder how it worked in the first
place.  Any idea?

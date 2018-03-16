Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA256B0010
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:26:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u3so5315620pgp.13
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:26:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z21si6252560pfa.33.2018.03.16.15.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:26:18 -0700 (PDT)
Subject: Re: [PATCH v12 15/22] selftests/vm: powerpc implementation to check
 support for pkey
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-16-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <dc588e0e-eda5-1267-5806-91b9b95e28bf@intel.com>
Date: Fri, 16 Mar 2018 15:26:09 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-16-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
>  #define PAGE_SIZE (0x1UL << 16)
> -static inline int cpu_has_pku(void)
> +static inline bool is_pkey_supported(void)
>  {
> -	return 1;
> +	/*
> +	 * No simple way to determine this.
> +	 * lets try allocating a key and see if it succeeds.
> +	 */
> +	int ret = sys_pkey_alloc(0, 0);
> +
> +	if (ret > 0) {
> +		sys_pkey_free(ret);
> +		return true;
> +	}
> +	return false;
>  }

The point of doing this was to have a test for the CPU that way separate
from the syscalls.

Can you leave cpu_has_pkeys() in place?

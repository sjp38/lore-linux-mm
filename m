Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7656B002A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:55:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h11so5821704pfn.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:55:36 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w13si5647941pge.181.2018.03.16.14.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:55:35 -0700 (PDT)
Subject: Re: [PATCH v12 02/22] selftests/vm: rename all references to pkru to
 a generic name
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-3-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <61350ceb-974f-6039-ae1e-f2626c405676@intel.com>
Date: Fri, 16 Mar 2018 14:55:26 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-3-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
>  int pkey_set(int pkey, unsigned long rights, unsigned long flags)
>  {
>  	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
> -	u32 old_pkru = __rdpkru();
> -	u32 new_pkru;
> +	u32 old_pkey_reg = __rdpkey_reg();
> +	u32 new_pkey_reg;

If we're not using the _actual_ instruction names ("rdpkru"), I think
I'd rather this be something more readable, like: __read_pkey_reg().

But, it's OK-ish the way it is.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>

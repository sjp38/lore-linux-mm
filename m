Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3256B0278
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:34:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j15-v6so2470194pff.12
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:34:41 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b13-v6si3286991pgw.478.2018.07.18.08.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:34:40 -0700 (PDT)
Subject: Re: [PATCH v14 07/22] selftests/vm: generic function to handle shadow
 key register
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-8-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ed8baf0c-7ccf-aa99-a88b-9b7697af89f4@intel.com>
Date: Wed, 18 Jul 2018 08:34:37 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-8-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> -	shifted_pkey_reg = (pkey_reg >> (pkey * PKEY_BITS_PER_PKEY));
> +	shifted_pkey_reg = right_shift_bits(pkey, pkey_reg);
>  	dprintf2("%s() shifted_pkey_reg: "PKEY_REG_FMT"\n", __func__,
>  			shifted_pkey_reg);
>  	masked_pkey_reg = shifted_pkey_reg & mask;

I'm not a fan of how this looks.  This is almost certainly going to get
the argument order mixed up at some point.

Why do we need this?  The description doesn't say.

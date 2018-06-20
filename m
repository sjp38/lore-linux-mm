Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C32AA6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:47:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x25-v6so1665902pfn.21
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:47:16 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v7-v6si2528814plp.304.2018.06.20.07.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 07:47:15 -0700 (PDT)
Subject: Re: [PATCH v13 08/24] selftests/vm: fix the wrong assert in
 pkey_disable_set()
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-9-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3c441309-1d35-eead-0c5d-1d7d20018219@intel.com>
Date: Wed, 20 Jun 2018 07:47:02 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-9-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:44 PM, Ram Pai wrote:
> If the flag is 0, no bits will be set. Hence we cant expect
> the resulting bitmap to have a higher value than what it
> was earlier
...
>  	if (flags)
> -		pkey_assert(read_pkey_reg() > orig_pkey_reg);
> +		pkey_assert(read_pkey_reg() >= orig_pkey_reg);
>  	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
>  		pkey, flags);
>  }

This is the kind of thing where I'd love to hear the motivation and
background.  This "disable a key that was already disabled" operation
obviously doesn't happen today.  What motivated you to change it now?

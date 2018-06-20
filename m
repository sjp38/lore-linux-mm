Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF93E6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:09:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a13-v6so1685576pfo.22
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:09:15 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f11-v6si2459180plr.316.2018.06.20.08.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 08:09:15 -0700 (PDT)
Subject: Re: [PATCH v13 17/24] selftests/vm: powerpc implementation to check
 support for pkey
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-18-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <20bc9696-3ae9-4eb9-40ce-9c477a8aaea2@intel.com>
Date: Wed, 20 Jun 2018 08:09:12 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-18-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

> -	if (cpu_has_pku()) {
> -		dprintf1("SKIP: %s: no CPU support\n", __func__);
> +	if (is_pkey_supported()) {
> +		dprintf1("SKIP: %s: no CPU/kernel support\n", __func__);
>  		return;
>  	}

I actually kinda wanted a specific message for when the *CPU* doesn't
support the feature.

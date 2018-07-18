Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A70EC6B0274
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:32:17 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q18-v6so2779968pll.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:32:17 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q129-v6si3442405pga.217.2018.07.18.08.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:32:16 -0700 (PDT)
Subject: Re: [PATCH v14 06/22] selftests/vm: typecast the pkey register
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-7-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8c468c61-615a-dd0d-2b73-d3218f38e3e4@intel.com>
Date: Wed, 18 Jul 2018 08:32:10 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-7-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> This is in preparation to accomadate a differing size register
> across architectures.

This is pretty fugly, and reading it again, I wonder whether we should
have just made it 64-bit, at least in all the printk's.  Or even

	prink("pk reg: %*llx\n", PKEY_FMT_LEN, pkey_reg);

But, I don't _really_ care in the end.

Acked-by: Dave Hansen <dave.hansen@intel.com>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC46F6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:45:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b9-v6so284158pla.19
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:45:30 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t85-v6si4051142pfj.231.2018.07.18.08.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:45:29 -0700 (PDT)
Subject: Re: [PATCH v14 10/22] selftests/vm: fix alloc_random_pkey() to make
 it really random
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-11-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b33e0850-f3ec-86b8-69e8-9e6afb289058@intel.com>
Date: Wed, 18 Jul 2018 08:45:26 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-11-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> alloc_random_pkey() was allocating the same pkey every time.
> Not all pkeys were geting tested. fixed it.

This fixes a real issue but also unnecessarily munges whitespace.  If
you rev these again, please fix the munging.  Otherwise:

Acked-by: Dave Hansen <dave.hansen@intel.com>

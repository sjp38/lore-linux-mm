Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 280696B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:23:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t24so8876314pfe.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:23:30 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c3-v6si9752753plo.45.2018.03.05.11.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:23:29 -0800 (PST)
Subject: Re: [PATCH v12 08/11] mm: Clear arch specific VM flags on protection
 change
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <df5344a2-f28d-7828-b76b-107dc24be2dd@linux.intel.com>
Date: Mon, 5 Mar 2018 11:23:27 -0800
MIME-Version: 1.0
In-Reply-To: <f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, davem@davemloft.net
Cc: mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, willy@infradead.org, hughd@google.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, jglisse@redhat.com, dave.jiang@intel.com, dan.j.williams@intel.com, anthony.yznaga@oracle.com, nadav.amit@gmail.com, zi.yan@cs.rutgers.edu, aarcange@redhat.com, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, henry.willard@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 02/21/2018 09:15 AM, Khalid Aziz wrote:
> +/* Arch-specific flags to clear when updating VM flags on protection change */
> +#ifndef VM_ARCH_CLEAR
> +# define VM_ARCH_CLEAR	VM_NONE
> +#endif
> +#define VM_FLAGS_CLEAR	(ARCH_VM_PKEY_FLAGS | VM_ARCH_CLEAR)

Shouldn't this be defining

# define VM_ARCH_CLEAR	ARCH_VM_PKEY_FLAGS

on x86?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

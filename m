Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A84B6B02B7
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:49:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y12so16569239pfe.8
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:49:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t3-v6si14964361ply.192.2018.05.08.09.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:49:42 -0700 (PDT)
Subject: Re: [PATCH v2] x86/boot/64/clang: Use fixup_pointer() to access
 '__supported_pte_mask'
References: <20180508162829.7729-1-glider@google.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <a67943d1-f7e8-c465-ce8d-a9c9a0a6f653@linux.intel.com>
Date: Tue, 8 May 2018 09:49:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180508162829.7729-1-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, mingo@kernel.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

On 05/08/2018 09:28 AM, Alexander Potapenko wrote:
> Clang builds with defconfig started crashing after commit fb43d6cb91ef
> ("x86/mm: Do not auto-massage page protections")
> This was caused by introducing a new global access in __startup_64().
> 
> Code in __startup_64() can be relocated during execution, but the compiler
> doesn't have to generate PC-relative relocations when accessing globals
> from that function. Clang actually does not generate them, which leads
> to boot-time crashes. To work around this problem, every global pointer
> must be adjusted using fixup_pointer().

Looks good to me.  Thanks for adding the comment, especially!

Reviewed-by: Dave Hansen <dave.hansen@intel.com>

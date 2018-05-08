Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C80CC6B0287
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:30:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d9-v6so1883395plj.4
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:30:54 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d18-v6si15710583plr.265.2018.05.08.07.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 07:30:52 -0700 (PDT)
Subject: Re: [PATCH] x86/boot/64/clang: Use fixup_pointer() to access
 '__supported_pte_mask'
References: <20180508121638.174022-1-glider@google.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1f69bdb6-df5e-d709-064a-4f6fdd6e11a7@linux.intel.com>
Date: Tue, 8 May 2018 07:30:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180508121638.174022-1-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, mingo@kernel.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

On 05/08/2018 05:16 AM, Alexander Potapenko wrote:
> Similarly to commit 187e91fe5e91
> ("x86/boot/64/clang: Use fixup_pointer() to access 'next_early_pgt'"),
> '__supported_pte_mask' must be also accessed using fixup_pointer() to
> avoid position-dependent relocations.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")

In the interests of standalone changelogs, I'd really appreciate an
actual explanation of what's going on here.  Your patch makes the code
uglier and doesn't fix anything functional from what I can see.

The other commit has some explanation, so it seems like the rules for
accessing globals in head64.c are different than other files because...
something.

The functional problem here is that it causes insta-reboots?

Do we have anything we can do to keep us from recreating these kinds of
regressions all the time?

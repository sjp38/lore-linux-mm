Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9FE46B02AF
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:15:47 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s143-v6so417184lfs.9
        for <linux-mm@kvack.org>; Tue, 15 May 2018 13:15:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g78-v6sor300684lfi.23.2018.05.15.13.15.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 May 2018 13:15:46 -0700 (PDT)
Date: Fri, 11 May 2018 10:43:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3] x86/boot/64/clang: Use fixup_pointer() to access
 '__supported_pte_mask'
Message-ID: <20180511074337.3fa5htarfcsbeeqy@kshutemo-mobl1>
References: <20180509091822.191810-1-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509091822.191810-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: dave.hansen@linux.intel.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

On Wed, May 09, 2018 at 11:18:22AM +0200, Alexander Potapenko wrote:
> Clang builds with defconfig started crashing after commit fb43d6cb91ef
> ("x86/mm: Do not auto-massage page protections")
> This was caused by introducing a new global access in __startup_64().
> 
> Code in __startup_64() can be relocated during execution, but the compiler
> doesn't have to generate PC-relative relocations when accessing globals
> from that function. Clang actually does not generate them, which leads
> to boot-time crashes. To work around this problem, every global pointer
> must be adjusted using fixup_pointer().
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

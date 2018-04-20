Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88A6B6B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:59:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d13so5015153pfn.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:59:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q7-v6si6202523plk.129.2018.04.20.10.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 10:59:32 -0700 (PDT)
Date: Fri, 20 Apr 2018 20:59:28 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] x86/mm: Decouple dynamic __PHYSICAL_MASK from AMD SME
Message-ID: <20180420175928.nup3hcqxe2u4ugln@black.fi.intel.com>
References: <20180410093339.49257-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410093339.49257-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 10, 2018 at 09:33:39AM +0000, Kirill A. Shutemov wrote:
> AMD SME claims one bit from physical address to indicate whether the
> page is encrypted or not. To achieve that we clear out the bit from
> __PHYSICAL_MASK.
> 
> The capability to adjust __PHYSICAL_MASK is required beyond AMD SME.
> For instance for upcoming Intel Multi-Key Total Memory Encryption.
> 
> Factor it out into a separate feature with own Kconfig handle.
> 
> It also helps with overhead of AMD SME. It saves more than 3k in .text
> on defconfig + AMD_MEM_ENCRYPT:
> 
> 	add/remove: 3/2 grow/shrink: 5/110 up/down: 189/-3753 (-3564)
> 
> We would need to return to this once we have infrastructure to patch
> constants in code. That's good candidate for it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
> 
> Previously, I've posted the patch with MKTME patchset, but it's useful on
> its own as it reduces text size for kernel with AMD_MEM_ENCRYPT enabled.
> 
> Please consider applying.

Any feedback on this?

-- 
 Kirill A. Shutemov

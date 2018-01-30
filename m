Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9D966B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 17:52:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u26so12299853pfi.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:52:21 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0055.outbound.protection.outlook.com. [104.47.42.55])
        by mx.google.com with ESMTPS id j10si10075701pgs.467.2018.01.30.14.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 14:52:20 -0800 (PST)
Subject: Re: [PATCHv3 0/3] x86/mm/encrypt: Cleanup and switching between
 paging modes
References: <20180124163623.61765-1-kirill.shutemov@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <830ed299-53a7-f357-9301-5b6577d55f30@amd.com>
Date: Tue, 30 Jan 2018 16:52:13 -0600
MIME-Version: 1.0
In-Reply-To: <20180124163623.61765-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/24/2018 10:36 AM, Kirill A. Shutemov wrote:
> This patcheset is a preparation set for boot-time switching between
> paging modes. Please review and consider applying.
> 
> Code around sme_populate_pgd() is unnecessary complex and hard to modify.
> 
> This patchset rewrites it in more stream-lined way to add support of
> boot-time switching between paging modes.
> 
> I haven't tested the patchset on hardware capable of memory encryption.

Tested-by: Tom Lendacky <thomas.lendacky@amd.com>

> 
> v3:
>  - Move all page table related functions into mem_encrypt_identity.c
> v2:
>  - Rebased to up-to-date tip
> 
> Kirill A. Shutemov (3):
>   x86/mm/encrypt: Move page table helpers into separate translation unit
>   x86/mm/encrypt: Rewrite sme_populate_pgd() and
>     sme_populate_pgd_large()
>   x86/mm/encrypt: Rewrite sme_pgtable_calc()
> 
>  arch/x86/mm/Makefile               |  14 +-
>  arch/x86/mm/mem_encrypt.c          | 578 +------------------------------------
>  arch/x86/mm/mem_encrypt_identity.c | 563 ++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/mm_internal.h          |   1 +
>  4 files changed, 574 insertions(+), 582 deletions(-)
>  create mode 100644 arch/x86/mm/mem_encrypt_identity.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

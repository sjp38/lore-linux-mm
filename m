Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 825486B03A0
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:38:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so5065484wmu.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:38:33 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id w67si2697917wma.76.2017.02.28.04.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 04:38:32 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id i17so2577628wmf.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:38:32 -0800 (PST)
Date: Tue, 28 Feb 2017 12:38:30 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCHv3 15/33] x86/efi: handle p4d in EFI pagetables
Message-ID: <20170228123830.GF28416@codeblueprint.co.uk>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-16-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217141328.164563-16-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 17 Feb, at 05:13:10PM, Kirill A. Shutemov wrote:
> Allocate additional page table level and change efi_sync_low_kernel_mappings()
> to make syncing logic work with additional page table level.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> ---
>  arch/x86/platform/efi/efi_64.c | 33 +++++++++++++++++++++++----------
>  1 file changed, 23 insertions(+), 10 deletions(-)

Looks fine to me, but I haven't tested it.

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

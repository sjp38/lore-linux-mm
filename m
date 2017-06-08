Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 996C86B02FD
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 10:09:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n7so5046160wrb.0
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:09:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y79sor1020165wrc.2.2017.06.08.07.09.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 07:09:24 -0700 (PDT)
Date: Thu, 8 Jun 2017 15:09:22 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCHv7 04/14] x86/boot/efi: Fix __KERNEL_CS definition of GDT
 entry on 64-bit configuration
Message-ID: <20170608140922.GC3220@codeblueprint.co.uk>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
 <20170606113133.22974-5-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606113133.22974-5-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 06 Jun, at 02:31:23PM, Kirill A. Shutemov wrote:
> Define __KERNEL_CS GDT entry as long mode (.L=1, .D=0) on 64-bit
> configuration.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> ---
>  arch/x86/boot/compressed/eboot.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

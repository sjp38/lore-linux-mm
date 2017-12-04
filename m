Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B56E6B0266
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 14:31:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v69so10897264wrb.3
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 11:31:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si281315eda.452.2017.12.04.11.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 11:31:16 -0800 (PST)
Date: Mon, 4 Dec 2017 20:31:07 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv3 2/5] x86/boot/compressed/64: Print error if 5-level
 paging is not supported
Message-ID: <20171204193107.ni42cydrxp5utg3n@pd.tnic>
References: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
 <20171204124059.63515-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171204124059.63515-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Dec 04, 2017 at 03:40:56PM +0300, Kirill A. Shutemov wrote:
> We cannot proceed booting if the machine doesn't support the paging mode
> kernel was compiled for.
> 
> Getting error the usual way -- via validate_cpu() -- is not going to
> work. We need to enable appropriate paging mode before that, otherwise
> kernel would triple-fault during KASLR setup.
> 
> This code will go away once we get support for boot-time switching
> between paging modes.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: <stable@vger.kernel.org>	[4.14+]
> ---
>  arch/x86/boot/compressed/misc.c       | 16 ++++++++++++++++
>  arch/x86/boot/compressed/pgtable_64.c |  2 +-
>  2 files changed, 17 insertions(+), 1 deletion(-)

Reported-and-tested-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

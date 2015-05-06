Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A82F16B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 06:46:14 -0400 (EDT)
Received: by wiun10 with SMTP id n10so17170341wiu.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 03:46:14 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id e7si1054988wib.9.2015.05.06.03.46.12
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 03:46:13 -0700 (PDT)
Date: Wed, 6 May 2015 12:46:09 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 3/7] mtrr, x86: Remove a wrong address check in
 __mtrr_type_lookup()
Message-ID: <20150506104609.GC22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1427234921-19737-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, Mar 24, 2015 at 04:08:37PM -0600, Toshi Kani wrote:
> __mtrr_type_lookup() checks MTRR fixed ranges when
> mtrr_state.have_fixed is set and start is less than
> 0x100000.  However, the 'else if (start < 0x1000000)'
> in the code checks with a wrong address as it has
> an extra-zero in the address.  The code still runs
> correctly as this check is meaningless, though.
> 
> This patch replaces the wrong address check with 'else'
> with no condition.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/kernel/cpu/mtrr/generic.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Applied, thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

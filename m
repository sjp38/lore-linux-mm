Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5AB146B00B5
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 12:16:34 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id c11so1628040qad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 09:16:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350302608-8322-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1350302608-8322-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 15 Oct 2012 17:16:13 +0100
Message-ID: <CAHkRjk7akwhcmeYV_Ank-YVotUMW0mN_1xeu5zbXWE+z5d9xdg@mail.gmail.com>
Subject: Re: [PATCH] asm-generic, mm: PTE_SPECIAL cleanup
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org

On 15 October 2012 13:03, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Advertise PTE_SPECIAL through Kconfig option and consolidate dummy
> pte_special() and mkspecial() in <asm-generic/pgtable.h>
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/Kconfig                             |    6 ++++++
>  arch/alpha/include/asm/pgtable.h         |    2 --
>  arch/arm/include/asm/pgtable.h           |    3 ---
>  arch/arm64/Kconfig                       |    1 +
>  arch/arm64/include/asm/pgtable.h         |    2 --

For the arm64 bits:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

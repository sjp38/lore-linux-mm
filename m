Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 462926B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 19:43:12 -0500 (EST)
Received: by iacb35 with SMTP id b35so6071505iac.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 16:43:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1112180128070.21784@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1112180128070.21784@swampdragon.chaosbits.net>
Date: Sat, 17 Dec 2011 16:43:11 -0800
Message-ID: <CANN689GQyzMGfnxsKmni7wDFpqo4s=D3dpu6w9UxN0tKbqakig@mail.gmail.com>
Subject: Re: [PATCH] Use 'do {} while (0)' for empty flush_tlb_fix_spurious_fault()
 macro
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Juhl <jj@chaosbits.net>
Cc: x86@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, Dec 17, 2011 at 4:32 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> If one builds the kernel with -Wempty-body one gets this warning:
>
> =A0mm/memory.c:3432:46: warning: suggest braces around empty body in an =
=91if=92 statement [-Wempty-body]
>
> due to the fact that 'flush_tlb_fix_spurious_fault' is a macro that
> can sometimes be defined to nothing.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Looks good to me. I'd be happy with either that or Al's alternative suggest=
ion.

Reviewed-by: Michel Lespinasse <walken@google.com>

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

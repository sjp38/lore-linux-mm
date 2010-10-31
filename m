Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D44DE8D005B
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 17:32:23 -0400 (EDT)
From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH/RFC] m68k/sun3: Kill pte_unmap() warnings
References: <alpine.DEB.2.00.1010312135110.22279@ayla.of.borg>
Date: Sun, 31 Oct 2010 22:32:18 +0100
In-Reply-To: <alpine.DEB.2.00.1010312135110.22279@ayla.of.borg> (Geert
	Uytterhoeven's message of "Sun, 31 Oct 2010 21:38:35 +0100 (CET)")
Message-ID: <m2wroynj4t.fsf@igel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Sam Creasey <sammy@sammy.net>, Andrew Morton <akpm@linux-foundation.org>, Linux/m68k <linux-m68k@vger.kernel.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> Which one is preferable?
>
> -------------------------------------------------------------------------------
> Since commit 31c911329e048b715a1dfeaaf617be9430fd7f4e ("mm: check the argument
> of kunmap on architectures without highmem"), we get lots of warnings like
>
> arch/m68k/kernel/sys_m68k.c:508: warning: passing argument 1 of a??kunmapa?? from incompatible pointer type
>
> As m68k doesn't support highmem anyway, open code the calls to kmap() and
> kunmap() (the latter is a no-op) to kill the warnings.

I prefer this one, it matches all architectures without CONFIG_HIGHPTE.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

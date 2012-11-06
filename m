Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 289536B004D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:38:21 -0500 (EST)
Date: Tue, 6 Nov 2012 14:38:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/16] mm: fix cache coloring on x86_64 architecture
Message-Id: <20121106143819.4309031c.akpm@linux-foundation.org>
In-Reply-To: <1352155633-8648-8-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-8-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon,  5 Nov 2012 14:47:04 -0800
Michel Lespinasse <walken@google.com> wrote:

> Fix the x86-64 cache alignment code to take pgoff into account.
> Use the x86 and MIPS cache alignment code as the basis for a generic
> cache alignment function.
> 
> The old x86 code will always align the mmap to aliasing boundaries,
> even if the program mmaps the file with a non-zero pgoff.
> 
> If program A mmaps the file with pgoff 0, and program B mmaps the
> file with pgoff 1. The old code would align the mmaps, resulting in
> misaligned pages:
> 
> A:  0123
> B:  123
> 
> After this patch, they are aligned so the pages line up:
> 
> A: 0123
> B:  123

We have a bit of a history of fiddling with coloring and finding that
the changes made at best no improvement.  Or at least, that's my
perhaps faulty memory of it.

This one needs pretty careful testing, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

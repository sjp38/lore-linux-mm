Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id E96F16B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:55:17 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so7575597vbk.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:55:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <509D0F86.30607@gmail.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-4-git-send-email-walken@google.com>
	<509D0F86.30607@gmail.com>
Date: Mon, 12 Nov 2012 03:55:16 -0800
Message-ID: <CANN689E4jXT-VA3j54h_MBgCCc9YK0o_E7PY326NnvdiHmAgFQ@mail.gmail.com>
Subject: Re: [PATCH 03/16] mm: check rb_subtree_gap correctness
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Dave Jones <davej@redhat.com>

On Fri, Nov 9, 2012 at 6:13 AM, Sasha Levin <levinsasha928@gmail.com> wrote:
> While fuzzing with trinity inside a KVM tools (lkvm) guest, using today's -next
> kernel, I'm getting these:
>
> [  117.007714] free gap 7fba0dd1c000, correct 7fba0dcfb000
> [  117.019773] map_count 750 rb -1
> [  117.028362] ------------[ cut here ]------------
> [  117.029813] kernel BUG at mm/mmap.c:439!
>
> Note that they are very easy to reproduce.

Thanks for the report. I had trouble reproducing this on Friday, but
after Hugh came up with an easy test case I think I have it figured
out. I sent out a proposed fix as "[PATCH 0/3] fix missing
rb_subtree_gap updates on vma insert/erase". Let's follow up the
discussion there if necessary.

Cheers,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

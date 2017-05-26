Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC026B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 03:22:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l1so2515509oib.4
        for <linux-mm@kvack.org>; Fri, 26 May 2017 00:22:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x85si12960254oia.309.2017.05.26.00.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 00:22:04 -0700 (PDT)
Received: from mail-ua0-f178.google.com (mail-ua0-f178.google.com [209.85.217.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4C057239EF
	for <linux-mm@kvack.org>; Fri, 26 May 2017 07:22:03 +0000 (UTC)
Received: by mail-ua0-f178.google.com with SMTP id j17so1596931uag.3
        for <linux-mm@kvack.org>; Fri, 26 May 2017 00:22:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170526041853.GA27213@la.guarana.org>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
 <CALCETrWACTFPDrpuZgoPqeRLU4ZooDjHOpQaNCFmCfVCHM-sHQ@mail.gmail.com> <20170526041853.GA27213@la.guarana.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 26 May 2017 00:21:41 -0700
Message-ID: <CALCETrUCsWxLNGTN=CUZWWagghEwVdPYr6UFzwTENFTr6JTfRA@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>
Cc: Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 25, 2017 at 9:18 PM, Kevin Easton <kevin@guarana.org> wrote:
> (If it weren't for that, maybe you could point the last entry in the PML4
> at the PML4 itself, so it also works as a PML5 for accessing kernel
> addresses? And of course make sure nothing gets loaded above
> 0xffffff8000000000).

This was an old trick done for a very different reason: it lets you
find your page tables at virtual addresses that depend only on the VA
whose page table you're looking for and the top-level slot that points
back to itself.  IIRC Windows used to do this for its own memory
management purposes.  A major downside is that an arbitrary write
vulnerability lets you write your own PTEs without any guesswork.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

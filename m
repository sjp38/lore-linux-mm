Date: Mon, 14 Oct 2002 18:02:30 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support,
 2.5.42-F8
In-Reply-To: <Pine.LNX.4.44.0210141739510.8792-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.44.0210141800160.9302-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> if this is really an issue then we could force vma->vm_page_prot to
> PROT_NONE within remap_file_pages(), so at least all subsequent faults
> will be PROT_NONE and the user would have to explicitly re-mprotect()
> the vma again to change this.

i've added this to the -G1 patch at:

        http://redhat.com/~mingo/remap-file-pages-patches/

    Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

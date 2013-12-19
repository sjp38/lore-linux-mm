Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 19 Dec 2013 15:42:06 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219204206.GC10905@kvack.org>
References: <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel> <20131219182920.GG30640@kvack.org> <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com> <20131219192621.GA9228@kvack.org> <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com> <20131219195352.GB9228@kvack.org> <CA+55aFy5zg_cJueMZFzuqr06rT-hwnHhvBpM6W9657sxnCzxKg@mail.gmail.com> <CA+55aFwu_KN+1Ep5RmgFTvBdH3xRJDmCjZ9Fo_pH28hTdiHyiQ@mail.gmail.com> <CA+55aFzW_MKS35Mn9cfZV2A4BH_ONZCmmdk1pQtztbxwPYsxpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzW_MKS35Mn9cfZV2A4BH_ONZCmmdk1pQtztbxwPYsxpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 20, 2013 at 05:31:29AM +0900, Linus Torvalds wrote:
> On Fri, Dec 20, 2013 at 5:11 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So here's the same patch, but with stuff moved around a bit, and the
> > "oops, couldn't create page" part fixed.
> >
> > Bit it's still totally and entirely untested.
> 
> Btw, I think this actually fixes a bug, in that it doesn't leak the
> page reference count if the do_mmap_pgoff() call fails.
> 
> That said, that looks like just a memory leak, not explaining the
> problem Dave sees. And maybe I'm missing something.
> 
> And no, I still haven't actually tested this at all. Is there an aio
> tester that is worth trying?

There are a few tests in the libaio source, some in xfstests and fio, and 
a few I've got sitting around.  To specifically exercise the page migration 
code path, there's a test at http://www.kvack.org/~bcrl/aio-numa-test.c .

		-ben

>                    Linus

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

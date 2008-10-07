Date: Wed, 8 Oct 2008 00:05:18 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008000518.13f48462@lxorguk.ukuu.org.uk>
In-Reply-To: <20081007211038.GQ20740@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
	<2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com>
	<20081007211038.GQ20740@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Oct 2008 23:10:38 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> > Sorry, no.
> > This description still doesn't explain why this interface is needed.
> > 
> > The one of the points is this interface is used by another person or not.
> > You should explain how large this interface benefit has.
> > 
> > Andi kleen explained this interface _can_  be used another one.
> > but nobody explain who use it actually.
> 
> Anyone who doesn't want to use fixed addresses. 

Can use shm_open and mmap to get POSIX standard shm behaviour via a sane
interface without adding more crap to the sys3 shm madness. 

Sorry this patch is completely bogus - introduce the user programs
involved to 1990s technology. They have to be updated to use such a
change as is proposed anyway so they might as well use shm_open/mmap at
which point no kernel changes are needed.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

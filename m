Date: Wed, 8 Oct 2008 01:20:59 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081007232059.GU20740@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name> <2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com> <20081007211038.GQ20740@one.firstfloor.org> <20081008000518.13f48462@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081008000518.13f48462@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 12:05:18AM +0100, Alan Cox wrote:
> On Tue, 7 Oct 2008 23:10:38 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > Sorry, no.
> > > This description still doesn't explain why this interface is needed.
> > > 
> > > The one of the points is this interface is used by another person or not.
> > > You should explain how large this interface benefit has.
> > > 
> > > Andi kleen explained this interface _can_  be used another one.
> > > but nobody explain who use it actually.
> > 
> > Anyone who doesn't want to use fixed addresses. 
> 
> Can use shm_open and mmap to get POSIX standard shm behaviour via a sane

I don't think shm_open can attach to SYSV shared segments. Or are you
proposing to add "sysvshmfs" to make that possible? 

> interface without adding more crap to the sys3 shm madness. 
> 
> Sorry this patch is completely bogus - introduce the user programs
> involved to 1990s technology. 

As already listed in an earlier email, but here again:

- There are legacy interfaces that cannot be really changed who use sysv shm
(e.g. X shm and others -- just do a ipcs on your system) 
- An system call emulation as in qemu obviously has to implement the
existing system call semantics.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 8 Oct 2008 01:23:22 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081007232322.GV20740@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name> <2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com> <20081007211038.GQ20740@one.firstfloor.org> <2f11576a0810071438x59e51b74rc8c1919c14739395@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0810071438x59e51b74rc8c1919c14739395@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 06:38:07AM +0900, KOSAKI Motohiro wrote:
> >> Sorry, no.
> >> This description still doesn't explain why this interface is needed.
> >>
> >> The one of the points is this interface is used by another person or not.
> >> You should explain how large this interface benefit has.
> >>
> >> Andi kleen explained this interface _can_  be used another one.
> >> but nobody explain who use it actually.
> >
> > Anyone who doesn't want to use fixed addresses.
> 
> yup.
> however, almost application doesn't use new flag because almost
> application want to works on cross platform. (or merely lazy)
> then, this explain isn't enough, imo.

You're arguing that there shouldn't be any Linux extensions
to system calls ever because it would break compatibility? 

You're at least 15 years too late with that. Linux extensions
are there all over.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

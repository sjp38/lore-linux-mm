Date: Wed, 8 Oct 2008 09:33:25 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008093325.3d0d3bd6@lxorguk.ukuu.org.uk>
In-Reply-To: <20081007235737.GD7971@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
	<2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com>
	<20081007211038.GQ20740@one.firstfloor.org>
	<20081008000518.13f48462@lxorguk.ukuu.org.uk>
	<20081007232059.GU20740@one.firstfloor.org>
	<20081008004030.7a0e9915@lxorguk.ukuu.org.uk>
	<20081007235737.GD7971@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Perhaps I'm confused but my /dev/shm doesn't have any such files,
> but I see a variety of shm segments in ipcs.
> 
> What would the path passed to shm_open look like?

Well right now they don't get exposed as they are created unlinked but
that is a trivial tweak to mm/shmem.c.

> > and nobody is wanting to map those at fixed addresses.
> 
> You're saying it should always use the address as a search hint?

Nothing of the sort. I'm pointing out that mmap and shm_open already
provide all the needed interfaces for this for real world applications
today.
> 
> Just changing the semantics unconditionally would seem risky to me. After 
> all as you point out they are primarily for compatibility and for that keeping
> old semantics would seem better to me.

We don't need to change any semantics, there is a perfectly good
alternative standards based interface. At most you might want to make the
sys3 shared memory segments appear in /dev/shm/ somewhere.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

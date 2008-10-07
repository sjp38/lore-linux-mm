Date: Wed, 8 Oct 2008 00:40:30 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008004030.7a0e9915@lxorguk.ukuu.org.uk>
In-Reply-To: <20081007232059.GU20740@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
	<2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com>
	<20081007211038.GQ20740@one.firstfloor.org>
	<20081008000518.13f48462@lxorguk.ukuu.org.uk>
	<20081007232059.GU20740@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Can use shm_open and mmap to get POSIX standard shm behaviour via a sane
> 
> I don't think shm_open can attach to SYSV shared segments. Or are you
> proposing to add "sysvshmfs" to make that possible? 

Actually you can do so. As it stands today the SYS3 SHM interface code
does the following

	create a char array in the form SYS%08ld, key
	open it on shmfs

> - There are legacy interfaces that cannot be really changed who use sysv shm
> (e.g. X shm and others -- just do a ipcs on your system) 

They can be changed and nobody is wanting to map those at fixed addresses.

> - An system call emulation as in qemu obviously has to implement the
> existing system call semantics.

Which it can do perfectly well using shm_open to create its SYS3
SHM objects. In fact theoertically we could bin the whole of SYS3 shm and
push it into glibc emulation if we wanted.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

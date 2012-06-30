Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id DA6B76B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 22:42:32 -0400 (EDT)
Received: by obhx4 with SMTP id x4so190506obh.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 19:42:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340315835-28571-6-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	<1340315835-28571-6-git-send-email-riel@surriel.com>
Date: Fri, 29 Jun 2012 19:42:31 -0700
Message-ID: <CANN689GtyRXcZ4OisN+DeiaA63RC8h2YLwif5fgvK8u4tzzuSA@mail.gmail.com>
Subject: Re: [PATCH -mm v2 05/11] mm: get unmapped area from VMA tree
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, Jun 21, 2012 at 2:57 PM, Rik van Riel <riel@surriel.com> wrote:
> For topdown allocations, we need to keep track of the highest
> mapped VMA address, because it might be below mm->mmap_base,
> and we only keep track of free space to the left of each VMA
> in the VMA tree. =A0It is tempting to try and keep track of
> the free space to the right of each VMA when running in
> topdown mode, but that gets us into trouble when running on
> x86, where a process can switch direction in the middle of
> execve.

Just a random thought - one way to handle this could be to always have
some sentinel VMA at the end of the address space. Some architectures
might already have it in the form of the vsyscall page, or we could
always have some other sentinel right above the last usable user page
?

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

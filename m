From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912142300.PAA05447@google.engr.sgi.com>
Subject: Re: 2.3 Pagedir allocation/free and update races
Date: Tue, 14 Dec 1999 15:00:19 -0800 (PST)
In-Reply-To: <19991214111351.U822@mff.cuni.cz> from "Jakub Jelinek" at Dec 14, 99 11:13:51 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Tue, Dec 14, 1999 at 01:46:00AM -0800, Kanoj Sarcar wrote:
> > This note describes races in the procedures that allocate and free
> > user level page directories. Platform code maintainers, please
> > read.
> 
> pgd_alloc/free are never invoked from interrupts and the kernel code is not
> preemptive, so per-CPU caches are safe, aren't they?
> 
> Cheers,
>     Jakub

Yes, I am sorry for the misleading logic in my note. Per-cpu caches are 
safe (I wonder why it was taken out for i386). For architectures that 
have to do set_pgdir() though, the pgdir update code might be racy, 
unless the arch code has locks to protect the page directory scanning.

Btw, Linus indicated to me he ran into problems with the patch, and 
will be pulling it out in the next pre-release. I will take a closer look 
at the code.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Message-ID: <3A132470.4F93CFF5@cse.iitkgp.ernet.in>
Date: Wed, 15 Nov 2000 19:04:00 -0500
From: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
MIME-Version: 1.0
Subject: Re: Question about pte_alloc()
References: <3A12363A.3B5395AF@cse.iitkgp.ernet.in> <20001115105639.C3186@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Wed, Nov 15, 2000 at 02:07:38AM -0500, Shuvabrata Ganguly wrote:
> >
> > it appears from the code that pte_alloc() might block since it allocates
> > a page table with GFP_KERNEL if the page table doesnt already exist. i
> > need to call pte_alloc() at interrupt time.
>
> You cannot safely play pte games at interrupt time.  You _must_ do
> this in the foreground.
>

why is that ? or where can i find code that explains why i cant touch pte
tables at interrupt time ?

>
>  >Basically i want to map some
> > kernel memory into user space as soon as the device gives me data.
>
> Why can't you just let the application know that the event has
> occurred and then let it mmap the data itself?
>

Two reasons:-
i) since kernel memory is unswappable i dont want to allocate a big buffer
and transfer it to the user when the device has filled it with data. instead
i want to allocate a page, fill it with data and give it to the user process.

ii) if i allocate in pages and let the user know that a page of data has
arrived, it will take a lot of context switches.

basically i want the kernel to allocate memory on behalf of a process, and
pass the virtual address of that buffer to the user when it does a read. this
is somewhat like the "fbuf" scheme.
can that be done in the linux kernel at all ?

cheers,
joy



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Reply-To: <cprash@wipinfo.soft.net>
From: "Prashanth C." <cprash@wipinfo.soft.net>
Subject: RE: kmem_cache_init() question
Date: Fri, 18 Jun 1999 09:48:33 +0530
Message-ID: <000801beb941$a0b3e6f0$b7e0a8c0@prashanth.wipinfo.soft.net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <14184.50648.347245.288706@dukat.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Jun 1999 13:39:12 +0530, "Prashanth C."
> <cprash@wipinfo.soft.net> said:
>
>> I found that num_physpages is initialized in mem_init() function
>> (arch/i386/mm/init.c).  But start_kernel() calls kmem_cache_init() before
>> mem_init().  So, num_physpages will always(?) be zero when the above code
>> segment is executed.
>
>> Is num_physpages is initialized somewhere else before kmem_cache_init()
is
>> called by start_kernel()?
>
> The great thing about having all the source code is that if you can't
> instantly find the answer to such a question just by searching code, it
> takes no time at all to add a
>
>	printk ("num_physpages is now %lu\n", num_physpages);
>
> to init.c to find out for yourself. :)
>
> And if this turns out to be a real bug, do let us know...
>
> --Stephen

Yes, it is a bug.  Infact I found this bug when I tried to print values of
few varibles in kmem_cache_init() using printk().  Since, I have just now
started getting familiar with the MM code, I was not sure if I was missing
something :)

- Prashanth

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

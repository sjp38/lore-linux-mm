Message-ID: <480918B0.2070800@windriver.com>
Date: Fri, 18 Apr 2008 16:54:56 -0500
From: Jason Wessel <jason.wessel@windriver.com>
MIME-Version: 1.0
Subject: Re: 2.6.25-mm1: not looking good
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080417164034.e406ef53.akpm@linux-foundation.org> <20080417171413.6f8458e4.akpm@linux-foundation.org> <48080FE7.1070400@windriver.com> <20080418073732.GA22724@elte.hu>
In-Reply-To: <20080418073732.GA22724@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Jason Wessel <jason.wessel@windriver.com> wrote:
>
>   
>>> [...] The final initcall is init_kgdbts() and disabling KGDB 
>>> prevents the hang.
>>>       
> incidentally, just today, in overnight testing i triggered a similar 
> hang in the KGDB self-test:
>
>   http://redhat.com/~mingo/misc/config-Thu_Apr_17_23_46_36_CEST_2008.bad
>
> to get a similar tree to the one i tested, pick up sched-devel/latest 
> from:
>
>    http://people.redhat.com/mingo/sched-devel.git/README 
>
> pick up that failing .config, do 'make oldconfig' and accept all the 
> defaults to get a comparable kernel to mine. (kgdb is embedded in 
> sched-devel.git.)
>
> the hang was at:
>
> [   12.504057] Calling initcall 0xffffffff80b800c1: init_kgdbts+0x0/0x1b()
> [   12.511298] kgdb: Registered I/O driver kgdbts.
> [   12.515062] kgdbts:RUN plant and detach test
> [   12.520283] kgdbts:RUN sw breakpoint test
> [   12.524651] kgdbts:RUN bad memory access test
> [   12.529052] kgdbts:RUN singlestep breakpoint test
>
>   

So I pulled your tree and I would agree there was a problem.  But it
seems unrelated to kgdb.  I bisected the tree because it worked starting
with the kgdb-light merge. 

It fails once with the patch below, but it is not clear as to why other
than the lock must have something to do with it.

I'll submit a patch to the kgdb test suite to increase the amount of
loops through the single step test as it is it can definitely catch
things :-)

Jason.

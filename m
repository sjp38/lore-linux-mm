Received: by fg-out-1718.google.com with SMTP id e12so68932fga.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 08:25:30 -0800 (PST)
Message-ID: <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
Date: Thu, 21 Feb 2008 17:25:29 +0100
From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
	 <6101e8c40802191018t668faf3avba9beeff34f7f853@mail.gmail.com>
	 <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>
	 <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>
	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>
	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>
	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bart Van Assche <bart.vanassche@gmail.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-mm@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

and add plus CC's
On 2/21/08, Oliver Pinter <oliver.pntr@gmail.com> wrote:
> it is reproductable with SLUB?
> /* sorry for the bad english, but i not learned it .. */
> On 2/21/08, Bart Van Assche <bart.vanassche@gmail.com> wrote:
> > On Thu, Feb 21, 2008 at 9:48 AM, Bart Van Assche
> > <bart.vanassche@gmail.com> wrote:
> > > On Wed, Feb 20, 2008 at 10:42 PM, Oliver Pinter <oliver.pntr@gmail.com>
> > wrote:
> > > >
> > > > hmm it is with slub or slab?
> > >
> > > All tests were performed with SLAB. Please note that it's not yet
> > > clear to me whether this is an issue with the SLAB allocator or
> > > another memory allocation mechanism. In the meantime I also noticed
> > > different behavior between the 2.6.22.18 and 2.6.24.2 kernel: with
> > > 2.6.22.18 I see unbounded growth of the memory used, while with
> > > 2.6.24.2 memory usage increases from about 30 MB to about 70 MB and
> > > then keeps at the same level. I am still performing more tests (a.o.
> > > minimizing the kernel config). I will add the results of these tests
> > > to the kernel bugzilla entry.
> >
> > I have added a new graph to
> > http://bugzilla.kernel.org/show_bug.cgi?id=9991, namely a graph
> > showing memory usage for a PAE-kernel booted with mem=1G and with a
> > minimized kernel config. The graph shows that memory usage increases
> > to a certain limit. Other tests have shown that this limit is
> > proportional to the amount of memory specified in mem=... This is not
> > a SLAB leak: as the numbers show, slab usage remains constant during
> > all tests.
> >
> > I'm puzzled by these results ...
> >
> > Bart.
> > --
> > Met vriendelijke groeten,
> >
> > Bart Van Assche.
> >
> --
> Thanks,
> Oliver
>
--
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

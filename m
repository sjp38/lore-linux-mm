Date: Mon, 25 Sep 2000 19:21:48 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925192148.A24362@home.ds9a.nl>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000925014137.B6249@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 01:41:37AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> We're talking about shrink_[id]cache_memory change. That have _nothing_ to do
> with the VM changes that happened anywhere between test8 and test9-pre6.
> 
> You were talking about a different thing.

Ok, sorry. Kernel development is proceding at a furious pace and I sometimes
lose track. 

> I consider the current approch the wrong way to go and for this reason I
> prefer to spend time porting/improving classzone.

I seem to remember that people were impressed by classzone, but that the
implementation was very non-trivial and hard to grok. One of the reasons
Rik's vm made it (so far) is that it is pretty straightforward, with all the
marks of the right amount of simplicity. 

> In the meantime if you want to go back to 2.4.0-test1-ac22-class++ to give
> it a try under swap to see the difference in the behaviour and compare
> (Mike said it's still an order of magnitude faster with his "make -j30
> bzImage" testcase and he's always very reliable in his reports).

There is no such thing as 'under swap'. There are lots of loadpatterns that
will generate different kinds of memory pressure. Just calling it 'under
swap' gives entirely the wrong impression. 

Although Mike's compile is a relevant benchmark, every VM has cases for
which it excels, and cases for which it sucks. This appears to be a general
property of VM design. 

Given knowledge of the algorithms used, you can always dream up a situation
where it will fail. It's a bit like writing the halting problem algorithm.
Same goes the other way around, every VM will have a 'shining benchmark' -
hence the invention of benchmarketing.

We used to have a bad virtual memory implementation that was sometimes well
tuned so a lots of ordinary cases showed acceptable performance. We now have
an elegant VM that works reasonably well, but needs more tweaking.

What is the point of all this ranting? Think twice before embarking on
'rivaling virtual memory' code. Energies spent on Rik's VM will yield far
higher differential improvement. 

Regards,


bert hubert

-- 
PowerDNS                     Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

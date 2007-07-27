From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Fri, 27 Jul 2007 18:51:28 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <200707271345.55187.dhazelton@enter.net> <1185574124.6342.31.camel@Homer.simpson.net>
In-Reply-To: <1185574124.6342.31.camel@Homer.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707271851.29061.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 27 July 2007 18:08:44 Mike Galbraith wrote:
> On Fri, 2007-07-27 at 13:45 -0400, Daniel Hazelton wrote:
> > On Friday 27 July 2007 06:25:18 Mike Galbraith wrote:
> > > On Fri, 2007-07-27 at 03:00 -0700, Andrew Morton wrote:
> > > > So hrm.  Are we sure that updatedb is the problem?  There are quite a
> > > > few heavyweight things which happen in the wee small hours.
> > >
> > > The balance in _my_ world seems just fine.  I don't let any of those
> > > system maintenance things run while I'm using the system, and it
> > > doesn't bother me if my working set has to be reconstructed after
> > > heavy-weight maintenance things are allowed to run.  I'm not seeing
> > > anything I wouldn't expect to see when running a job the size of
> > > updatedb.
> > >
> > > 	-Mike
> >
> > Do you realize you've totally missed the point?
>
> Did you notice that I didn't make one disparaging remark about the patch
> or the concept behind it?   Did you notice that I took _my time_  to
> test, to actually look at  the problem?  No, you're too busy running
> your mouth to appreciate the efforts of others.

If you're done being an ass, take note of the fact that I never even said you 
were doing that. What I was commenting on was the fact that you (and a lot of 
the other developers) seem to keep saying "It doesn't happen here, so it 
doesn't matter!" - ie: If I don't see something happening, it doesn't matter.

> <snips load of useless spleen venting>
>
> Do yourself a favor, go dig into the VM source.  Read it, understand it
> (not terribly easy), _then_ come back and preach to me.

I've been trying to do that since the thread started. Note that you snipped 
where I said (and I'm going to paraphrase myself) "There is another way to 
fix this, but I don't have the understanding necessary".

Now, once more, I'm going to ask: What is so terribly wrong with swap 
prefetch? Why does it seem that everyone against it says "Its treating a 
symptom, so it can't go in"?

Try coming up with an answer that isn't "I don't see the problem on my $10K 
system" or similar - try explaining it based on the *technical* merits. Does 
it cause the processor cache to get thrashed? Does it create locking 
problems?

I stand by my statements, as vitriolic as you and Rene seem to want to get 
over it. So far in this thread I have not seen one bit of *technical* 
discussion over the merits, just the bits I've simplified and stated before.

> Have a nice day.

I am. You being nasty when somebody gets fed up with a line of BS doesn't stop 
me from having a nice day. Only thing that could make my life any better 
would be to have the questions I've asked answered, rather than having 
supposedly intelligent people act like trolls.

DRH

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

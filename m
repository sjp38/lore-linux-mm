Subject: Re: Basic testing shows 2.3.99-pre9-3 bad, pre9-2 good
References: <Pine.LNX.4.10.10005211215060.1429-100000@penguin.transmeta.com>
From: "Quintela Carreira Juan J." <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Sun, 21 May 2000 12:17:25 -0700 (PDT)"
Date: 21 May 2000 21:32:04 +0200
Message-ID: <yttn1ljaedn.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Lawrence Manning <lawrence@aslak.demon.co.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

linus> On Sun, 21 May 2000, Rik van Riel wrote:

>> On Sun, 21 May 2000, Lawrence Manning wrote:
>> 
>> > That's my observation anyway.  I did some dd and bonnie tests
>> > and got abismal results :-( Machine unusable during dd write
>> > etc.  pre9-2 on the other hand is close to being as smooth as,
>> > say, 2.3.51.  What happened? ;)

linus> What happened was really that I did a partial integration just to make it
linus> easier to synchronize. I wanted to basically have pre9-2 + quintela's
linus> patch, but I had too many emails to go through and too many changes of my
linus> own in this area, so I made pre9-3 available so that others could help me
linus> synchronize.

linus> So on't despair, pre9-3 is definitely just a temporary mix of patches, and
linus> is lacking the balancing that Quintela did. 

Hi Linus
   I am working in introducing my balancing changes in pre9-3, but I
   am having problems with it.  Now my machines get deadlocked and I
   get a lot of Oopses.  I am investigating on that.  I get Oops
   indeed in the pre9-3 vanilla kernel.  I am studying it to write a
   report of the situation.

   My SMP machine is new, It has passed 6 hours of memtest86 memory
   checker, but I don't know what to blame at the moment.  I am
   compiling for my old UP machines to test the differences.

Later, Juan.

PD.
<advertising>
   Yes I am having deadlocks, Conectiva (http://www.conectiva.com.br/)and
   my department in the University (http://carpanta.dc.fi.udc.es/)
   have bought me an SMP machine.
</advertising>
   
-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

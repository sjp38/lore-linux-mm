Received: from localhost.localdomain (groudier@ppp-104-238.villette.club-internet.fr [194.158.104.238])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA29551
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 15:07:30 -0500
Date: Wed, 27 Jan 1999 21:11:45 +0100 (MET)
From: Gerard Roudier <groudier@club-internet.fr>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901271605.QAA05048@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990127204123.386B-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Thomas Sailer <sailer@ife.ee.ethz.ch>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 27 Jan 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, 26 Jan 1999 21:48:59 +0100 (MET), Gerard Roudier
> <groudier@club-internet.fr> said:
> 

[ ... ]

> > There are bunches of things that are widespread used nowadays and that 
> > should have disappeard since years if people were a bit more concerned 
> > by technical and progress considerations.
> 
> Yes.  I see what you mean.  We should immediately remove Linux support
> for FAT filesystems, the ISA bus and 8086 virtual mode.
> 
> Not.

AFAIK, it is what M$$ is intending to do. If the Linux strategy is to be 
the greatest O/S for obsolete hardware, we can support that stuff years
after M$$ has dropped the support of it.

> > For example, it seems that 32 bits systems are not enough to provide a
> > flat virtual addressing space far larger than the physical address space
> > needed for applications (that was the primary goal of virtual memory
> > invention).
> 
> *One* of the primary goals.  The other was protected multitasking.  The
> x86 architecture today is perfectly well capable of supporting mutliple
> 32-bit address spaces within a 36 bit (64GB) physical address space, and
> large multiuser environments would benefit enormously from such an
> environment.

64 GB of memory needs 36 address lines. It is obvious to handle that on 64
bit machines that exists since _years_, but very painfull on 32 bit
addressing machines. Implementing complex algorithms for handling this
stupidity is stupidity by itself.  32 bit VM architecture is a 25 years
old technology. The fact that it still exists nowadays is because the
market place was more concerned by $$ than by real progress.  If the PC
market had started in 1980, then it might have happen that modern PCs
would use rather Z80s type processors at something like 1 GHZ that 32 bit
PII at 400 MHz.

Just thinking of the ridiculous price fast 32 bits processors are sold
today is the proof, in my opinion, that 32 bit is definitely _dead_.
People that still want to make efforts for that stuff are just stupid, in
my opinion. 

> > A device that requires more contiguous space than 1 PAGE for its 
> > support is crap. 
> 
> So?  IDE is crap because it doesn't support multiple outstanding

Indeed.

> commands.  If you honestly believe that this means we should remove IDE
> support from the kernel, then you are living on another planet where
> getting real work done by real users doesn't matter.  Fact is, we _can_
> support this stuff, and users want us to.

I live on the euro-planet and yours is just a satellit. :-))

Regards,
   Gerard.


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

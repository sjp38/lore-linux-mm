Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA27167
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 11:06:20 -0500
Date: Wed, 27 Jan 1999 16:05:43 GMT
Message-Id: <199901271605.QAA05048@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990126210417.374A-100000@localhost>
References: <36ADAAC4.82165F6E@ife.ee.ethz.ch>
	<Pine.LNX.3.95.990126210417.374A-100000@localhost>
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>
Cc: Thomas Sailer <sailer@ife.ee.ethz.ch>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 26 Jan 1999 21:48:59 +0100 (MET), Gerard Roudier
<groudier@club-internet.fr> said:

> I suggest to allow some application program to decide what stuff to
> victimize and to be able to tell the kernel about, 

Yep, there is already a madvise() fuction in most modern unixen: it is
especially useful for giving cache hints.  

> There are bunches of things that are widespread used nowadays and that 
> should have disappeard since years if people were a bit more concerned 
> by technical and progress considerations.

Yes.  I see what you mean.  We should immediately remove Linux support
for FAT filesystems, the ISA bus and 8086 virtual mode.

Not.

> For example, it seems that 32 bits systems are not enough to provide a
> flat virtual addressing space far larger than the physical address space
> needed for applications (that was the primary goal of virtual memory
> invention).

*One* of the primary goals.  The other was protected multitasking.  The
x86 architecture today is perfectly well capable of supporting mutliple
32-bit address spaces within a 36 bit (64GB) physical address space, and
large multiuser environments would benefit enormously from such an
environment.

> A device that requires more contiguous space than 1 PAGE for its 
> support is crap. 

So?  IDE is crap because it doesn't support multiple outstanding
commands.  If you honestly believe that this means we should remove IDE
support from the kernel, then you are living on another planet where
getting real work done by real users doesn't matter.  Fact is, we _can_
support this stuff, and users want us to.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Received: from granada.iram.es (root@granada.iram.es [150.214.224.100])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA28896
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 12:03:53 -0400
Date: Wed, 7 Apr 1999 17:59:04 +0200 (METDST)
From: Gabriel Paubert <paubert@iram.es>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <199904062253.PAA12352@piglet.twiddle.net>
Message-ID: <Pine.HPP.3.96.990407174343.13413D-100000@gra-ux1.iram.es>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: davem@redhat.com
Cc: mingo@chiara.csoma.elte.hu, sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 6 Apr 1999, David Miller wrote:

>    Date: Wed, 7 Apr 1999 00:49:18 +0200 (CEST)
>    From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
> 
>    It should be 'inode >> 8' (which is done by the log2
>    solution). Unless i'm misunderstanding something.
> 
> Consider that:
> 
> (((unsigned long) inode) >> (sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
> 
> sort of approximates this and avoids the funny looking log2 macro. :-)

May I disagree ? Compute this expression in the case sizeof(struct inode) 
is a large power of 2. Say 0x100, the shift count becomes (0x100 & ~0xff),
or 0x100. Shifts by amounts larger than or equal to the word size are
undefined in C AFAIR (and in practice on most architectures which take
the shift count modulo some power of 2). 

I have needed quite often a log2 estimate of integer values but I don't
know of any tricks or expression to make it fast on machines which don't
have an instruction which counts the number of most significant zero bits. 
It is trivial to count the number of least significant zero bits if you
have an instruction which counts the most significant zero bits, but not
the other way around. 

	Regards,
	Gabriel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

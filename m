Date: Fri, 13 Oct 2000 18:43:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] atomic pte updates and pae changes, take 2
In-Reply-To: <Pine.LNX.4.21.0010132002440.25522-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10010131841120.962-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 13 Oct 2000, Ben LaHaise wrote:
>
> Hey folks

Me likee.

This looks much nicer. The hack turned into something that looks quite
ddesigned. 

Ingo, I'd like you to comment on all the PAE issues just in case, but I
personally don't have any real issues any more. Small nit: I dislike the
"__HAVE_ARCH_xxx" approach, and considering that most architectures will
probably want to do something specific anyway I wonder if we should get
rid of that and just make architectures have their own code.

Thanks,

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

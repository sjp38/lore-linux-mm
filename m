Date: Sun, 15 Oct 2000 08:07:41 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: [RFC] atomic pte updates and pae changes, take 2
In-Reply-To: <Pine.LNX.4.10.10010131841120.962-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010150802251.30587-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Oct 2000, Linus Torvalds wrote:

> Ingo, I'd like you to comment on all the PAE issues just in case, but
> I personally don't have any real issues any more. [...]

there is one small thing apart of the issue Stephen noticed, barrier()
between the two 32-bit writes should IMO be smp_wmb() instead. It should
not make any difference on current x86 CPUs, but if any future x86 SMP
implementation relaxes memory ordering, it will be easier to sort things
out.

	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

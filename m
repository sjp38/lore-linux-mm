Date: Wed, 13 Aug 2008 10:09:32 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
In-Reply-To: <48A303EE.8070002@redhat.com>
Message-ID: <alpine.LFD.1.10.0808131007530.3462@nehalem.linux-foundation.org>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu>
 <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu> <48A303EE.8070002@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


On Wed, 13 Aug 2008, Ulrich Drepper wrote:
> 
> The real problem is: what to do if somebody complains?

Ulrich, I don't understand why you worry more about a _potential_ (and 
fairly unlikely) complaint, than about a real one today.

Thinking ahead may be good, but you take it to absolutely ridiculous 
heights, to the point where you make potential problems be bigger than 
-actual- problems.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

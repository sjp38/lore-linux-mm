From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
Date: Wed, 12 Mar 2008 10:21:55 +1100
References: <20080311104653.995564000@nick.local0.net> <200803112244.23693.nickpiggin@yahoo.com.au> <6934efce0803111412g471e5c72i491b7b87c473ee8d@mail.gmail.com>
In-Reply-To: <6934efce0803111412g471e5c72i491b7b87c473ee8d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803121021.55652.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: npiggin@nick.local0.net, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 12 March 2008 08:12, Jared Hulbert wrote:
> >  > (doh, please ignore the previous "x/6" patches, they're old. The
> >  > new ones are these x/7 set)
> >
> >  Ah shit and now I use the wrong address. Sorry. If you could take
> >  it in your heart to correct it when you reply to me, I won't have
> >  to mailbomb everyone again.
>
> is there a [patch 6/7] and [patch 7/7]  I didn't see them...

Hmm, they were s390 patches that didn't get cc'ed to linux-mm, sorry.
They implement pte_special and struct page less XIP for s390, and
don't touch any core code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

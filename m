Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.31.0103192300570.1195-100000@penguin.transmeta.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 20 Mar 2001 01:19:43 -0700
In-Reply-To: Linus Torvalds's message of "Mon, 19 Mar 2001 23:03:02 -0800 (PST)"
Message-ID: <m1lmq03l9c.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On Mon, 19 Mar 2001, Linus Torvalds wrote:
> >
> > Although I'd prefer to see somebody check out the other architectures,
> > to do the (pretty trivial) changes to make them support properly
> > threaded page faults. I'd hate to have two pre-patches without any
> > input from other architectures..
> 
> These are the trivial fixes to make -pre5 be spinlock-debugging-clean and
> fix the missing unlock in copy_page_range(). I'd really like to hear from
> architecture maintainers if possible.
> 
> 		Linus

Hmm.  It looks like remap_area_pages doesn't return an error...
- return 0;
+ return error;


Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 4 May 2000 23:51:04 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 7-4 VM killing (A solution)
In-Reply-To: <39126DB2.2DD7CAB3@sgi.com>
Message-ID: <Pine.LNX.4.10.10005042348560.870-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> On another note, noticed your change to shrink_mmap in 7-5:
> 
> -------
> -       count = nr_lru_pages >> priority;
> +       count = (nr_lru_pages << 1) >> priority;
> -------
> 
> Is this to defeat aging? If so, I think its overly cautious:
> if all an iteration of shrink_mmap did was to flip the referenced bit,
> then that iteration shouldn't be included in count (and in the
> current code it isn't). So why double the effort?

It was indeed because I thought we should defeat aging. But you're right,
the reference bit flip doesn't get counted. My bad, and I'll revert that
one (and you found the real reason for pages not getting free'd anyway)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

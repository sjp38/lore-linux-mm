Date: Thu, 13 Jan 2000 14:30:43 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001132213.OAA37225@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001131428250.2250-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 13 Jan 2000, Kanoj Sarcar wrote:
> 
> Yes, that's what everyone seems to be pointing at. As I mentioned, I am
> looking into this as I type. The only thing is, as Andrea points out, 
> 2.3 bh/irq handlers do not request HIGHMEM pages, so shouldn't the
> 2.3 kswapd do something more like: 
> 
>        more_work = 0;
>        for (i = 0; i < MAX_NR_ZONES; i++) {
> 		if (i != ZONE_HIGHMEM)
>                		more_work |= balance_zone(zone+i)

No, the other reason for kswapd is to get "smoother" behaviour, by trying
to keep some memory free. Also, while we don't use high-memory pages right
now in BH and irq contexts, I don't think that is something we need to
codify, and it may change in the future. There's no real reason per se for
not using them (except for complexity), so I'd hate to have a special case
for that case.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

Date: Sun, 7 May 2000 15:27:42 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Bug in classzone patch?
In-Reply-To: <391430AF.BC96942C@ucla.edu>
Message-ID: <Pine.LNX.4.21.0005071521080.479-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ cc'ed to linux-mm to let know people I was wrong about pgdat_list not
  null terminated, sorry ]

On Sat, 6 May 2000, Benjamin Redelings I wrote:

>-	pgdat->node_next = pgdat_list;
>+	pgdat->node_next = NULL;
> 	pgdat_list = pgdat;
>
>Hi Andrea,
>	I don't understand this bit of your classzone patch.  You say that this
>changes makes pgdat_list NULL-terminated.
>	However, pgdat_list is ALREADY null terminated:
>
>telomere:/usr/src/linux/mm> grep 'pgdat_list' *c
>page_alloc.c:pg_data_t *pgdat_list = (pg_data_t *)0;

Ah, I see, you're right. Thanks. (btw there's no reason to initialize the
pgdat_list to zero since it's global and it could fit in the .bss)

>Am I missing something, or is this a bug in your classzone patch?

Yes, it's a bug in the classzone patch that can trigger only in NUMA. I'll
fix it thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

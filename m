Date: Mon, 13 Mar 2000 15:31:42 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
In-Reply-To: <200003132328.PAA31009@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003131530080.1031-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 13 Mar 2000, Kanoj Sarcar wrote:
> 
> I am not sure about the zone lru_cache, since any claims without extensive
> performance testing is meaningless ... but it does look more cleaner
> theoretically. 

It's certainly "different", and LRU list itself will obviously not be as
"least recently used" as a global LRU. However, considering that we're
only using the LRU on a per-zone basis anyway, I think it should give the
same basic behaviour, no?

And it definitely looked cleaner ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

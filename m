From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003140023.QAA09732@google.engr.sgi.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
Date: Mon, 13 Mar 2000 16:23:10 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003131530080.1031-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 13, 2000 03:31:42 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Mon, 13 Mar 2000, Kanoj Sarcar wrote:
> > 
> > I am not sure about the zone lru_cache, since any claims without extensive
> > performance testing is meaningless ... but it does look more cleaner
> > theoretically. 
> 
> It's certainly "different", and LRU list itself will obviously not be as
> "least recently used" as a global LRU. However, considering that we're
> only using the LRU on a per-zone basis anyway, I think it should give the
> same basic behaviour, no?

Hmm, true ... I would like Ben to look over the low_on_memory and
zone_wake_kswapd setting/clearing part though.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Wed, 3 May 2000 00:54:55 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <ytt4s8g1vx0.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005030054220.3016-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2 May 2000, Juan J. Quintela wrote:

>You need to change the #define RAMSIZE to reflect your memory size in

hint: ramsize asks for not being a compile time thing ;)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-Id: <99Aug9.113711gmt+0100.66305@gateway.ukaea.org.uk>
Date: Mon, 9 Aug 1999 11:42:26 +0100
From: Neil Conway <nconway.list@ukaea.org.uk>
MIME-Version: 1.0
Subject: Re: [patch] care about the age of the pte even if we are low on memory
References: <Pine.LNX.4.10.9908082020250.29734-100000@laser.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> @@ -54,7 +54,7 @@
>          * Dont be too eager to get aging right if
>          * memory is dangerously low.
>          */
> -       if (!low_on_memory && pte_young(pte)) {
> +       if (pte_young(pte)) {

Ouch - let's try to keep those comments up to date folks.  Good comments
are better than 
none, but out-of-date ones...

Neil
(ps: I realise of course that this is only your v1 patch Andrea;
undoubtedly we can expect another half a dozen versions over the next 48
hours, one of which will contain updated comments ;-)))
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

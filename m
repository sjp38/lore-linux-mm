Message-ID: <3AD3872B.780F604C@mandrakesoft.com>
Date: Tue, 10 Apr 2001 18:20:27 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap_state.c thinko
References: <Pine.LNX.4.31.0104091316500.9383-100000@penguin.transmeta.com> <nnae5ompkm.fsf@code.and.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Antill <james@and.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Antill wrote:
> [1] Assuming that it doesn't kill performance by allocating non shared
> mappings, or chunks of swap etc. Ie. it just knows that it can
> allocate swap when it needs it later on.

Just FWIW...   from my VM-ignorant standpoint, it seems like for the
no-overcommit case "reserving" swap space is a much cheaper operation
than unconditionally allocating swap space....

-- 
Jeff Garzik       | Sam: "Mind if I drive?"
Building 1024     | Max: "Not if you don't mind me clawing at the dash
MandrakeSoft      |       and shrieking like a cheerleader."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Subject: Re: VM problem with 2.4.8-ac9 (fwd)
Date: Wed, 22 Aug 2001 22:14:05 +0100 (BST)
In-Reply-To: <Pine.LNX.4.33L.0108221622160.31410-100000@duckman.distro.conectiva> from "Rik van Riel" at Aug 22, 2001 04:25:49 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15ZfK9-0002I3-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>

> Suspect code would be:
> - tlb optimisations in recent -ac    (tasks dying with segfault)

Um the tlb optimisations go back to about 2.4.1-ac 8)

My guess would be the vm changes you and marcelo did
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

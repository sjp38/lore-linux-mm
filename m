Message-ID: <3997BBF2.4A426DF6@augan.com>
Date: Mon, 14 Aug 2000 11:29:22 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008111721.KAA03038@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

> And even if it doesn't help m68k, it definitely will help mips64, ia64
> and ARM (from what I am understanding from Russell). So, unless it is
> _breaking_ m68k, I would rather see the patch go in ...

No, it doesn't :) and I think I can start thinking to make it usable
under m68k.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

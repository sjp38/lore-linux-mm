Message-ID: <3993E87A.234FDEE7@augan.com>
Date: Fri, 11 Aug 2000 13:50:18 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008101718.KAA33467@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

> Also, as I have suggested before, the pte_page implementation in
> sparc/sparc64 should be cleaned up, and the usages of MAP_NR in the
> arm code. Russell, Linus has not put in the final patch that will
> allow DISCONTIGMEM systems to lay out their mem_map arrays however
> they see fit, I have resent it to him, if that is put in, we can get
> down to simplifying most of the DISCONTIG arch code.

Can you send me that patch? I'd like to check it, if it can be used for
the m68k port. m68k still has its own support for discontinous mem and
from what I've seen so far I'm not really convinced yet to give it up.
Small summary: m68k maps everything together into one virtual mapping
and uses the virtual address as index into memmap. That has the
advantage, that the address conversion stuff is concentrated in
__va/__pa and the rest stays simple (e.g. we don't have to deal with
multiple nodes). The only problem is that the generic code must not
assume that a mem zone is a physically continuos area (what is mostly
true, there are currently only two places, that are easy to fix).

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

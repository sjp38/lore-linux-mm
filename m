Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 36DD36B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 12:55:29 -0500 (EST)
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id B355E650027
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:55:22 +0100 (CET)
Subject: _PAGE_ACCESSED question
Message-ID: <OF638EF1BD.8D8D16E1-ONC12576A5.0061F7F5-C12576A5.00621EFE@transmode.se>
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Fri, 8 Jan 2010 18:51:44 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I hacking on 8xx ppc TLB handlers and I wonder about the _PAGE_ACCESSED
pte flag. Normally one set this flag in the TLB handler iff PRESENT is also set.
I know ACCESSED is used by SWAP but what more uses it?
I wonder because most embedded systems does not have SWAP so it is
tempting to skip updating ACCESSED in the TLB handler to save a few insn's
and a pte write when swap is disabled.

I also wonder if it allowed to clear the ACCESSED flag
when PRESENT is also cleared.

    Jocke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

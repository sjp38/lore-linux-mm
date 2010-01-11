Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE11E6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 02:40:44 -0500 (EST)
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id D1C09650003
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 08:40:40 +0100 (CET)
In-Reply-To: <OF638EF1BD.8D8D16E1-ONC12576A5.0061F7F5-C12576A5.00621EFE@LocalDomain>
References: <OF638EF1BD.8D8D16E1-ONC12576A5.0061F7F5-C12576A5.00621EFE@LocalDomain>
Subject: Re: _PAGE_ACCESSED question
Message-ID: <OF175C5711.E2611646-ONC12576A8.0029EAEC-C12576A8.002A1327@transmode.se>
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Mon, 11 Jan 2010 08:39:34 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Try asking the below question again:

Joakim Tjernlund/Transmode wrote on 08/01/2010 18:51:44:
>
> I hacking on 8xx ppc TLB handlers and I wonder about the _PAGE_ACCESSED
> pte flag. Normally one set this flag in the TLB handler iff PRESENT is also set.
> I know ACCESSED is used by SWAP but what more uses it?
> I wonder because most embedded systems does not have SWAP so it is
> tempting to skip updating ACCESSED in the TLB handler to save a few insn's
> and a pte write when swap is disabled.
>
> I also wonder if it allowed to clear the ACCESSED flag
> when PRESENT is also cleared.
>
>     Jocke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

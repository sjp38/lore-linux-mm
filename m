Date: Mon, 2 Oct 2000 13:51:31 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: Re: how can i add a kernel function ?
In-Reply-To: <39D880FA.CFCC31E7@SANgate.com>
Message-ID: <Pine.LNX.4.21.0010021349240.952-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, BenHanokh Gabriel wrote:

> hi
> 
> i'm trying to add a function of my own to my copy of fs/buffer.c
> 
> how can i export the symbol ?

add an entry to kernel/ksyms.c like this:

/* BenHakokh's function to do .... */
EXPORT_SYMBOL(bhg_doit);

also, make sure that the declaration of the function is visible to
kernel/ksyms.c.

Regards,
Tigran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

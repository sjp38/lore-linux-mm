Date: Tue, 17 Apr 2001 13:39:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Fwd: kernel BUG at page_alloc.c:75! / exit.c
Message-ID: <20010417133951.A2505@redhat.com>
References: <3AD30927.36D9D06@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3AD30927.36D9D06@gmx.de>; from ernte23@gmx.de on Tue, Apr 10, 2001 at 03:22:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ernte23@gmx.de
Cc: riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 10, 2001 at 03:22:47PM +0200, ernte23@gmx.de wrote:
> 
> Call Trace: [pci_release_regions+129/160] [<db800000>]
> [__free_pages+26/32] [free_pages+36/48] [pci_free_consistent+30/32]
> [<d08fbb1b>] [<d08fc6a0>] 
>        [pci_unregister_driver+47/80] [<d08fa000>] [<d08fa000>]
> [<d08fbb6a>] [<d08fc6a0>] [free_module+27/160] [<d08fa000>]
> [nls_iso8859-15:__insmod_nls_iso8859-15_O/var/2.4.4-pre1/kernel/fs/nls/nls_+0/96] 
>        [sys_delete_module+382/464] [<d08fa000>] [system_call+51/56] 

It's crashing in module unload, and it appears that the module is
freeing things which were not allocated (or freeing something twice).
It's a module bug --- report it on linux-kernel.  This does not look
like a mm bug.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

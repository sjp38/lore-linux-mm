Date: Thu, 20 Jul 2000 13:53:05 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000720174852Z156962-31297+1037@vger.rutgers.edu>
In-Reply-To: <d31z0osky8.fsf@lxplus015.cern.ch>
References: Timur Tabi's message of "Thu, 20 Jul 2000 13:06:21 -0500"
Subject: Re: phys-to-virt kernel mapping and ioremap()
Message-Id: <20000720191320Z131167-4586+10@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

** Reply to message from Jes Sorensen <jes@linuxcare.com> on 20 Jul 2000
20:41:51 +0200


> Timur> 1) Doesn't this mapping break the phys_to_virt and virt_to_phys
> Timur> macros?
> 
> Those two macros are not defined on ioremap'ed regions so it is
> irrelevant.

In that case, how do I do virt-to-phys and phys-to-virt translations on the
memory addresses for ioremap'ed regions?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

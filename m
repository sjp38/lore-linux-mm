Message-ID: <39770E77.CE0F5702@sangate.com>
Date: Thu, 20 Jul 2000 17:36:39 +0300
From: Mark Mokryn <mark@sangate.com>
MIME-Version: 1.0
Subject: Re: Marking a physical page as uncacheable
References: <20000719181648Z131171-4588+3@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Try ioremap_nocache()

-Mark

Timur Tabi wrote:
> 
> How can I make a kernel-allocated page of memory uncacheable?  The ioremap()
> function lets me specify a bitflag, so I know it's possible without using MTRR's.
> 
> --
> Timur Tabi - ttabi@interactivesi.com
> Interactive Silicon - http://www.interactivesi.com
> 
> When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

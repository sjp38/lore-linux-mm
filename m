Date: Thu, 20 Jul 2000 10:26:57 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000719181648Z131171-4588+3@kanga.kvack.org>
In-Reply-To: <39770E77.CE0F5702@sangate.com>
Subject: Re: Marking a physical page as uncacheable
Message-Id: <20000720154702Z131167-4587+7@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Mark Mokryn <mark@sangate.com> on Thu, 20 Jul 2000
17:36:39 +0300


> Try ioremap_nocache()

That's just a front-end to __ioremap().  I'm trying to make REAL RAM as
uncacheable, not PCI memory.  ioremap() does not work on real RAM, only high
addresses outside of physical memory.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 08 Jun 2000 16:58:13 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000608220756Z131165-245+106@kanga.kvack.org>
In-Reply-To: <20000608224744.E3886@redhat.com>
References: <20000608220756Z131165-245+106@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 04:44:21PM -0500
Subject: Re: Allocating a page of memory with a given physical address
Message-Id: <20000608222138Z131165-281+94@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from "Stephen C. Tweedie" <sct@redhat.com> on Thu, 8 Jun
2000 22:47:44 +0100


> No, nor is it likely to be added without a compelling reason.  Why do 
> you need this?

Unfortunately, it's part of my company's upcoming product, and I can't give a
detailed explanation.  I understand that such a response does not endear me to
the Linux community, but my hands are tied.  All I can say is that all of us
software guys here have given it a lot of thought, and we're absolutely positive
that we need this functionality.   We need to be able to read/write memory to
specific DIMMs.

In fact, it's one of the reasons why we support only Windows 2000, not Windows
NT or 95/98, because those older products don't have this kind of feature.

Hmmm... I just thought of something.  Knowing that there's a direct linear
mapping between virtual memory and physical memory in kernel space, I could
simply allocate a block of memory at a specific virtual address.  Would that be
any easier?






--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

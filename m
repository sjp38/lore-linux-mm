Date: Tue, 5 Jun 2001 13:25:27 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3B568C0B@MailAndNews.com>
Subject: Re: temp. mem mappings
Message-ID: <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from cohutta <cohutta@MailAndNews.com> on Tue, 5 Jun 2001
13:54:15 -0400


> what is the a preferred/correct method to map and unmap memory
> temporarily?

Allocate a virtual memory area using vmalloc and then save and modify the
pmd/pgd/pte to point to the physical memory you want.  To unmap, just undo the
previous steps.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

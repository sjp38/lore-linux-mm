Date: Tue, 5 Jun 2001 13:51:37 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <20010605194136.K26756@redhat.com>
References: <3B568C0B@MailAndNews.com> <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com>
	<LD7imD.A.DyE.aQSH7@dinero.interactivesi.com> ; from ttabi@interactivesi.com on Tue, Jun 05, 2001 at 01:25:27PM -0500
Subject: Re: temp. mem mappings
Message-ID: <93UtRC.A.gWG.8oSH7@dinero.interactivesi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "Stephen C. Tweedie" <sct@redhat.com> on Tue, 5 Jun
2001 19:41:36 +0100


> > Allocate a virtual memory area using vmalloc and then save and modify the
> > pmd/pgd/pte to point to the physical memory you want.  To unmap, just undo the
> > previous steps.
> 
> ioremap() is there for exactly that purpose. 

True, except that you can't use ioremap on normal memory, which is what I
assumed he was trying to do.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

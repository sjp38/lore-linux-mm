Subject: Re: Page Mapping
From: Ed L Cashin <ecashin@uga.edu>
Date: Mon, 19 Apr 2004 11:58:17 -0400
In-Reply-To: <87n058ng3m.fsf@uga.edu> (Ed L Cashin's message of "Mon, 19 Apr
 2004 11:26:53 -0400")
Message-ID: <87k70cnena.fsf@uga.edu>
References: <4070CB37.8070704@users.sourceforge.net>
	<407171E4.4020002@users.sourceforge.net> <87n058ng3m.fsf@uga.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kuas (gmane)" <ku4s@users.sourceforge.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed L Cashin <ecashin@uga.edu> writes:

...
> If you know the page is present in RAM and you want to access the
> contents of the page, you can convert it to a virtual address and then
> use that address.  There's the "phys_to_virt" function that you can
> use.

I should have mentioned that looking at get_user_pages in mm/memory.c
first is a good idea.  It will help remind you of all the
synchronization issues.

-- 
--Ed L Cashin            |   PGP public key:
  ecashin@uga.edu        |   http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

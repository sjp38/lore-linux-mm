Subject: Re: Page Mapping
From: Ed L Cashin <ecashin@uga.edu>
Date: Mon, 19 Apr 2004 11:26:53 -0400
In-Reply-To: <407171E4.4020002@users.sourceforge.net> ("Kuas's message of
 "Mon, 05 Apr 2004 10:49:08 -0400")
Message-ID: <87n058ng3m.fsf@uga.edu>
References: <4070CB37.8070704@users.sourceforge.net>
	<407171E4.4020002@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kuas (gmane)" <ku4s@users.sourceforge.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Kuas (gmane)" <ku4s@users.sourceforge.net> writes:

> Sorry, please ignore some of the previous question.
>
> I found the answer in Intel Developer guide v3. 'pte_t' consists of
> the base physical address of the page (20 MSB of pte_t) and page flags
> (12 LSB of pte_t). So to get the address, I just have to mask the
> pte_t with PAGE_MASK.
>
> Now the next question is can I just use that address and refer to it
> right away? Like using a pointer? Or I still have to use some MMU
> mechanism?

No, it's a physical address.  Normally, pointers inside the kernel
contain virtual addresses, and the MMU will translate them into
physical addresses automatically.

If you know the page is present in RAM and you want to access the
contents of the page, you can convert it to a virtual address and then
use that address.  There's the "phys_to_virt" function that you can
use.

> And I don't see anywhere in the page struct to know how big is the
> page filled? I don't think every page has all 4 KB filled, right? Or
> are all the pages zeroed out before being reassigned? So I still can
> read the whole page, just the last bytes will be 0x00 if it's not used.

I think that anonymous pages are usually set up copy-on-write from the
ZERO_PAGE.  They'll be all zero in parts of the page that haven't been
modified.  

-- 
--Ed L Cashin            |   PGP public key:
  ecashin@uga.edu        |   http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

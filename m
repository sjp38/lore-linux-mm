Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1BAVPS-0008WN-00
	for <linux-mm@kvack.org>; Mon, 05 Apr 2004 16:49:10 +0200
Received: from finn.gmane.org ([80.91.224.251])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 05 Apr 2004 16:49:10 +0200
Received: from ku4s by finn.gmane.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 05 Apr 2004 16:49:10 +0200
From: "Kuas (gmane)" <ku4s@users.sourceforge.net>
Subject: Re: Page Mapping
Date: Mon, 05 Apr 2004 10:49:08 -0400
Message-ID: <407171E4.4020002@users.sourceforge.net>
References: <4070CB37.8070704@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
In-Reply-To: <4070CB37.8070704@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, please ignore some of the previous question.

I found the answer in Intel Developer guide v3. 'pte_t' consists of the 
base physical address of the page (20 MSB of pte_t) and page flags (12 
LSB of pte_t). So to get the address, I just have to mask the pte_t with 
PAGE_MASK.

Now the next question is can I just use that address and refer to it 
right away? Like using a pointer? Or I still have to use some MMU mechanism?

And I don't see anywhere in the page struct to know how big is the page 
filled? I don't think every page has all 4 KB filled, right? Or are all 
the pages zeroed out before being reassigned? So I still can read the 
whole page, just the last bytes will be 0x00 if it's not used.

Kuas.


Kuas (gmane) wrote:
> Hello,
> 
> This might be very trivial question for people in this mailing list. I 
> need to know if my understanding is correct.
> 
> We are doing some experiment with Linux kernel for security. Right now, 
> we are trying to see some behavior in the Linux memory management. I am 
> trying to track and possibly scan (for now) all the pages that's just 
> brought into the memory. I am doing this in i386 arch and Linux kernel 
> 2.4.22.
> 
> I think it would be good to do it in: mm/memory.c in do_no_page(). At 
> the end of the function, I have references to pte_t and page struct of 
> the fresh new page that's just brought in from disk (not swapped).
> 
> This is diagram the diagram I'm going to refer:
> http://www.skynet.ie/~mel/projects/vm/guide/html/understand/node24.html
> 
>  From my understanding from the diagram of Linear Address to Page 
> conversion (please let me know if I'm correct or misunderstood). The 
> struct "pte_t->pte_low" an entry if PTE table, is the base 'physical' 
> address of the page. In this case I can just use it to reference the 
> page. I can't find any other conversion method to get another address.
> 
> Assuming I have that address, can I just direct reference that address 
> (assuming the address is physical and from kernel mode) or do I have to 
> use some methods to access the page content?
> 
> How do I know the size of the page that's filled though? I can't see 
> that information from the page struct.
> 
> Thanks in Advance for comments and information.
> 
> 
> Kuas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: [PATCH] bugfix for drivers/char/mem.c 
In-reply-to: Your message of "Sun, 01 Aug 1999 11:23:30 PDT."
             <199908011823.LAA32354@google.engr.sgi.com>
Date: Mon, 02 Aug 1999 14:27:05 +0100
From: Steven Hand <Steven.Hand@cl.cam.ac.uk>
Message-Id: <E11BI7Q-000048-00@heaton.cl.cam.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Steven Hand <Steven.Hand@cl.cam.ac.uk>, Linux-MM@kvack.orgSteven.Hand@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

>I see the problem. Can I suggest a simpler fix, based on the fact 
>that vread() returns 0 when count == 0?
>
>-	*ppos += p + virtr;
>+	*ppos += read + virtr;

Sure if you prefer it. 

The main reason I added the if(count) { ... } was just to avoid 
calling vread() when count is zero (since in this case there's no 
entry to find on the vmlist, and hence the for loop in vread() will 
just iterate over all vmalloc()'d areas before returning zero.)


S.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

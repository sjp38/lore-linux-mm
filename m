Message-ID: <20030313134224.27541.qmail@linuxmail.org>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Date: Thu, 13 Mar 2003 14:42:24 +0100
Subject: Re: 2.5.64-mm6
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Original Message ----- 
From: Andrew Morton <akpm@digeo.com> 
Date: 	Thu, 13 Mar 2003 03:26:15 -0800 
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org 
Subject: 2.5.64-mm6 
 
> . Added all of Russell King's PCMCIA changes.  If anyone tests this on 
>   cardbus/PCMCIA machines please let us know. 
 
Testing 2.5.64-mm6 on my NEC laptop, TI CardBus Bridge, 
3Com 3c575. No problems yet ;-) 
 
>   This means that large cache-cold executables start significantly faster. 
>   Launching X11+KDE+mozilla goes from 23 seconds to 16.  Starting OpenOffice 
>   seems to be 2x to 3x faster, and starting Konqueror maybe 3x faster too.  
>   Interesting. 
 
I feel the system a little bit faster and more responsive. I've also set 
max_timeslice to 50 to experiment a little more with interactive loads. 
 
Thanks! 
 
   Felipe 
 
-- 
______________________________________________
http://www.linuxmail.org/
Now with e-mail forwarding for only US$5.95/yr

Powered by Outblaze
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

Subject: Re: RFC: Speed freeing memory for suspend.
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <1110201773.422c55ad65110@webmail.topalis>
References: <1109812166.3733.3.camel@desktop.cunningham.myip.net.au>
	 <1110201773.422c55ad65110@webmail.topalis>
Content-Type: text/plain
Message-Id: <1110232951.25139.8.camel@desktop.cunningham.myip.net.au>
Mime-Version: 1.0
Date: Tue, 08 Mar 2005 09:02:31 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stefan Voelkel <stefan.voelkel@millenux.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

They're actually quite different, so far as I can see. My patch simply
increases the number of pages that the VM scans in one go. It doesn't
use allocation to create additional VM pressure.

Regards,

Nigel

On Tue, 2005-03-08 at 00:22, Stefan Voelkel wrote:
> Hello,
> 
> I tried to do something similar, if not in code but effekt, for apm -s, but
> it did not work and my mail was unanswered:
> 
>   http://marc.theaimsgroup.com/?l=linux-mm&m=110779400803717&w=2
> 
> regards
>   Stefan
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com
Bus: +61 (2) 6291 9554; Hme: +61 (2) 6292 8028;  Mob: +61 (417) 100 574

Maintainer of Suspend2 Kernel Patches http://softwaresuspend.berlios.de


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

From: Andreas Dilger <adilger@turbolinux.com>
Message-Id: <200106072109.f57L9FeW005798@webber.adilger.int>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106071545520.1156-100000@freak.distro.conectiva>
 "from Marcelo Tosatti at Jun 7, 2001 03:50:31 pm"
Date: Thu, 7 Jun 2001 15:09:15 -0600 (MDT)
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcello writes:
> Who did this change to refill_inactive_scan() in 2.4.6-pre1 ? 
> 
>         /*
>          * When we are background aging, we try to increase the page aging
>          * information in the system.
>          */
>         if (!target)
>                 maxscan = nr_active_pages >> 4;

A quick check in the l-k archives shows this was Zlatko Calusic
<zlatko.calusic@iskon.hr> who submitted the patch.  See

http://marc.theaimsgroup.com/?l=linux-kernel&m=99151955000988&w=4

Cheers, Andreas
-- 
Andreas Dilger  \ "If a man ate a pound of pasta and a pound of antipasto,
                 \  would they cancel out, leaving him still hungry?"
http://www-mddsp.enel.ucalgary.ca/People/adilger/               -- Dogbert
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 7 Jun 2001 15:50:31 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Background scanning change on 2.4.6-pre1
Message-ID: <Pine.LNX.4.21.0106071545520.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus, 


Who did this change to refill_inactive_scan() in 2.4.6-pre1 ? 

        /*
         * When we are background aging, we try to increase the page aging
         * information in the system.
         */
        if (!target)
                maxscan = nr_active_pages >> 4;

This is going to make all pages have age 0 on an idle system after some
time (the old code from Rik which has been replaced by this code tried to 
avoid that)

Could you please explain me the reasoning behind this change ?  

Thanks 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

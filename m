Message-ID: <20000422171006.3429.qmail@web113.yahoomail.com>
Date: Sat, 22 Apr 2000 10:10:06 -0700 (PDT)
From: Cacophonix <cacophonix@yahoo.com>
Subject: Re: swapping from pagecache?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--- Mark_H_Johnson.RTS@raytheon.com wrote:
> 
> 
>  - Are you saying that the performance of 2.3.99 is below that of 2.2 because
> the system is swapping?


I think you misunderstood me. I was indicating that performance is low 
because the system is swapping out _unused_ pages in the page cache - i.e,
files that have been closed by the application. 

--karthik


__________________________________________________
Do You Yahoo!?
Send online invitations with Yahoo! Invites.
http://invites.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 4 May 2000 15:59:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
In-Reply-To: <3911E111.DE0B5CFB@norran.net>
Message-ID: <Pine.LNX.4.21.0005041557390.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Roger Larsson wrote:

> Yes, I start scanning in the beginning every time - but I do not
> think that is so bad here, why?

Because you'll end up scanning the same few pages over and
over again, even if those pages are used all the time and
the pages you want to free are somewhere else in the list.

> a) It releases more than one page of the required zone before returning.
> b) It should be rather fast to scan.
> 
> I have been trying to handle the lockup(!), my best idea is to
> put in an artificial page that serves as a cursor...

You have to "move the list head".

If you do that, you are free to "start at the beginning"
(which has changed) each time...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

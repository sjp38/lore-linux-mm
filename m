Date: Mon, 15 May 2000 12:58:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <852568E0.0056F0BB.00@raylex-gh01.eo.ray.com>
Message-ID: <Pine.LNX.4.21.0005151256590.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000 Mark_H_Johnson.RTS@raytheon.com wrote:

>   What is the problem that killing processes is curing?

> I understand that the code that [has been/still is?] killing
> processes is doing so because there is no "free physical memory"
> - right now. Yet we have had code to do a schedule() instead of
> killing the job, and gave the system the chance to "fix" the
> lack of free physical memory problem

The problem was that while applications were busy freeing
memory themselves, other applications could happily "eat"
the pages that one application was freeing, leaving the
page-freeing application with no memory after the page
freeing was done.

With the patch I posted to linux-mm about an hour (??) ago,
this problem seems to be fixed.

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

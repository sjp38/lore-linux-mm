Date: Sat, 3 Jun 2000 21:17:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: classzone-31
In-Reply-To: <Pine.LNX.4.21.0006031643500.404-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006032113330.17414-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 3 Jun 2000, Andrea Arcangeli wrote:

> classzone-31 against 2.4.0-test1-ac7 is here:

In the process of writing the new VM code I've been looking
through your patch for some ideas and I have some questions.

1) could you explain your shrink_mmap changes?
   why do they work?

2) why are you backing out bugfixes made by Linus and
   other people?  what does your patch gain by that?
   (eg the do_try_to_free_pages stuff)

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

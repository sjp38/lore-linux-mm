Date: Wed, 19 Apr 2000 19:58:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] shrink_mmap() 2.3.99-pre6-3  (take 3)
In-Reply-To: <Pine.LNX.4.21.0004200035050.4117-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004191952110.12458-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2000, Andrea Arcangeli wrote:
> On Wed, 19 Apr 2000, Rik van Riel wrote:
> 
> >will be needed. It also doesn't eliminate a possible race
> >condition (afaik Ben is working on that one) in shrink_mmap().
> 
> Which shrink_mmap race condition?

Oh, you're right. I was worried about what would happen if we
looped back in the while() loop without the lock held, but now
I see that we grab the pagemap_lru_lock in unlock_continue...

I guess shrink_mmap() needs some comments. ;)

> >The patch does the following:
> >- remove possible race condition from truncate_inode_pages()
> 
> Which truncate_inode_pages race condition? Please provide a
> stack trace, it shouldn't take too time for you if you have the
> race condition in mind.

Stephen has already answered this question a number of
emails ago.

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

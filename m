Date: Thu, 20 Apr 2000 01:12:15 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] shrink_mmap() 2.3.99-pre6-3  (take 3)
In-Reply-To: <Pine.LNX.4.21.0004191952110.12458-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004200107540.4117-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Apr 2000, Rik van Riel wrote:

>I guess shrink_mmap() needs some comments. ;)

I tried to add commentary for everything that I considered subtle, but of
course I won't reject further commentary.

>> Which truncate_inode_pages race condition? Please provide a
>> stack trace, it shouldn't take too time for you if you have the
>> race condition in mind.
>
>Stephen has already answered this question a number of
>emails ago.

Maybe I missed the email (if it's not a pain for you please forward it to
me). thanks!

To me it seems the VFS avoids by design truncate_inode_pages() to be
called in parallel on the same inode (that was the problem you mentioned 
in earlier email).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

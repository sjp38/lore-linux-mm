Date: Thu, 20 Apr 2000 00:38:59 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] shrink_mmap() 2.3.99-pre6-3  (take 3)
In-Reply-To: <Pine.LNX.4.21.0004191903520.12458-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004200035050.4117-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Apr 2000, Rik van Riel wrote:

>will be needed. It also doesn't eliminate a possible race
>condition (afaik Ben is working on that one) in shrink_mmap().

Which shrink_mmap race condition?

>The patch does the following:
>- remove possible race condition from truncate_inode_pages()

Which truncate_inode_pages race condition? Please provide a stack trace,
it shouldn't take too time for you if you have the race condition in mind.

Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

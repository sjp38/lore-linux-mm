Date: Wed, 11 Oct 2000 14:38:00 -0400
Message-Id: <200010111838.e9BIc0M02456@trampoline.thunk.org>
In-reply-to: 
	<Pine.LNX.4.21.0010101738110.11122-100000@duckman.distro.conectiva>
	(message from Rik van Riel on Tue, 10 Oct 2000 17:53:57 -0300 (BRST))
Subject: Re: Updated 2.4 TODO List
From: tytso@mit.edu
References: <Pine.LNX.4.21.0010101738110.11122-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   > 2. Capable Of Corrupting Your FS/data
   > 
   >      * Non-atomic page-map operations can cause loss of dirty bit on
   >        pages (sct, alan)

   Is anybody looking into fixing this bug ?

According to sct (who's sitting next to me in my hotel room at ALS) Ben
LaHaise has a bugfix for this, but it hasn't been merged.

   >      * VM: Fix the highmem deadlock, where the swapper cannot create low
   >        memory bounce buffers OR swap out low memory because it has
   >        consumed all resources {CRITICAL} (old bug, already reported in
   >        2.4.0test6)

   Haven't been able to reproduce it on my 1GB test machine,
   but it might still be there. Can anyone confirm if this
   bug is still present ?

Note: all of the issues on the TODO list with the "VM:" prefix are from
a VM todo list you posted a week or two ago; so I'm assuming that you
know more about those issues than I do.....  (feel free to send me an
updated list and I'll merge it into the 2.4 TODO list.)

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

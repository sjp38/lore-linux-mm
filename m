Received: from web489-mc (web489-mc.mail.com [165.251.48.99])
	by rmx308-mta.mail.com (8.9.3/8.9.3) with SMTP id CAA20281
	for <linux-mm@kvack.org>; Mon, 4 Dec 2000 02:11:49 -0500 (EST)
Message-ID: <383856051.975913908567.JavaMail.root@web489-mc>
Date: Mon, 4 Dec 2000 02:11:48 -0500 (EST)
From: Michael Slater <mslater@usa.com>
Subject: questions on page swapping
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

   I am relatively new to linux memory management and i would like to
   have some pointers regarding swapping out pages.
   I was looking at the try_to_swap_out code and i have a few questions.
   1) If a page is swapped out does it go to the swap--cache as well as
   to the swap space in disk? 
   Also a comment says "If the page is in swap-cache we can just drop
   reference to it as it is up-to date in disk". Does it means that the
   page is just discarded and the page tables updated.

   2) What happens when a page is in swap-cache and is dirtied.Do
   we update the page in swap-cache before freeing it? Can we have a
   dirty page in swap-cache?

   3) What will be the page-count of a page when it is being swapped out
   . Is it 1 (as reference to the page in page-cache also counts i
   guess..)? If a page is only in swap-cache what is its count? Can a
   page be in swap/page cache at the same time.What will be its count
   then?

   Last but not the least: Where can i get a detailed notes on linux
   memory mgmt? Does paul-wilson have an updated version of his notes.

   Pl cc to me as i am not part of linux-mm gp. 

   Thanks in advance
   mike

______________________________________________
FREE Personalized Email at Mail.com
Sign up at http://www.mail.com/?sr=signup
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

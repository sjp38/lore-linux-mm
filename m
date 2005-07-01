Received: by wproxy.gmail.com with SMTP id i32so235162wra
        for <linux-mm@kvack.org>; Thu, 30 Jun 2005 19:52:57 -0700 (PDT)
Message-ID: <1e464b5b05063019521541222b@mail.gmail.com>
Date: Thu, 30 Jun 2005 16:52:57 -1000
From: Breno Leitao <breno.leitao@gmail.com>
Reply-To: Breno Leitao <breno.leitao@gmail.com>
Subject: Swap Memory and top
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Guys, 
  I have a crucial doubt about swap memory and top. 
  My top shows me that i have 0 kb of swapped file.
  But if i tells top to show the swap memory per process, it shows
that some process uses a swap, what causes me confusion, once it show
my swap is entire free.
Look:

Swap:   524280k total,        0k used,   524280k free,   203776k cached
 6049 root      15   0  108m  24m 7748 S  6.7  4.9   2:42.44  83m Xorg

The most funny occurs if I swap off my swap memory, and the top
continues to show the swapped out memory.
What is going on?

thanks in advance.

Best regards, 
Breno Leitao.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

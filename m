Message-ID: <20020920002137.72873.qmail@mail.com>
Content-Type: text/plain; charset="iso-8859-15"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From: "Lee Chin" <leechin@mail.com>
Date: Thu, 19 Sep 2002 19:21:37 -0500
Subject: Re: memory allocation on linux
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br, "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>
Cc: ebiederm+eric@ccr.net, leechin@mail.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
I downloaded the latest 2.5 Kernel.

I have a process trying to allocate a large amount of memory.

I have 4 GB physical memory in the system and more with swap space.

I have the kernel compiled with 8GB memory support.

However, I am unable to allocate more than 2GB for my process.

How can I acheive this?

Thanks
Lee
-- 
__________________________________________________________
Sign-up for your own FREE Personalized E-mail at Mail.com
http://www.mail.com/?sr=signup

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

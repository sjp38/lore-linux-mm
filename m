Received: from toughguy.net ([80.35.172.14]) by
          tsmtppp2.teleline.es (terra.es) with ESMTP id HBFY7200.G2C for
          <linux-mm@kvack.org>; Sat, 8 Mar 2003 18:35:26 +0100
Message-ID: <3E6A2A76.5080405@toughguy.net>
Date: Sat, 08 Mar 2003 18:37:58 +0100
From: Roberto Sierra <mrwhite@toughguy.net>
MIME-Version: 1.0
Subject: VM_GROWSDOWN/VM_GROWSUP
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello to everyone,

I'm playing around with mmap and threads, and sadly discovered 
VM_GROWSUP doesn't work at all while VM_GROWSDOWN works ok (as far as i 
have tested). I'm using a gentoo 2.4.19, but, apparently, it is known 
behaviour since vanilla 2.4.9.

I'd like to know if it is being worked on, or if otherwise it is 
deprecated, or maybe 2.5.x actually has changed this behaviour, but I 
haven't found any references. I have tried to ponder into the sources, 
but I'm not really skilled enough ;-)

Roberto

-- 
"There are 10 kinds of people in the world,
  those who understand binary and those who don't."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

Received: from m2vwall2.wipro.com (m2vwall2.wipro.com [164.164.27.52])
	by wiprom2mx1.wipro.com (8.11.3/8.11.3) with SMTP id f54Ca5Z18657
	for <linux-mm@kvack.org>; Mon, 4 Jun 2001 12:36:07 GMT
From: "Chandrashekar Nagaraj" <chandrashekar.nag@wipro.com>
Subject: How to redirect a task's o/p to different xterms ???
Date: Mon, 4 Jun 2001 12:19:57 +0530
Message-ID: <002601c0ecc2$9178d680$4433a8c0@wipro.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hi,
	We r working on a ISP( Internet service provider ). We have a board
for the client side running on Vxworks and for the server we r using a 
simulator running on Linux. The simulator has a menu based interface,
and supports operations such as ftp,telnet,logging and so on.
	We have an option for multiple file copy. But when the copy is
going on, we get output for each copy operation. But since the o/p appears
on a single terminal, the o/p becomes crowdy. So, we are planning
to redirect the o/p of each copy operation a different xterm. Any help
in this regard will be very helpful...

Thankx in advance.

bye,
chandra.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

From: "Stuart MacDonald" <stuartm@connecttech.com>
Subject: RE: opening a file inside the kernel module
Date: Wed, 29 Sep 2004 11:52:42 -0400
Message-ID: <001b01c4a63c$5b5bd4d0$294b82ce@stuartm>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
In-Reply-To: <001c01c4a5e9$114bf490$8200a8c0@RakeshJagota>
Sender: owner-linux-mm@kvack.org
From: linux-kernel-owner@vger.kernel.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Rakesh Jagota' <j.rakesh@gdatech.co.in>, 'Jeff Garzik' <jgarzik@pobox.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

> I want to implement socket from the module. I won't be having any user
> process running to handle the descriptors coming from socket. 
> Could you pl
> tell me how to handle the socket descriptor from the kernel module.

Check out fs/smbfs/sock.c.

..Stu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

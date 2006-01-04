Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Subject: Support for HIGHMEM in MIPS Architecture?
Date: Wed, 4 Jan 2006 11:22:41 +0530
Message-ID: <4BF47D56A0DD2346A1B8D622C5C5902C0122A397@soc-mail.soc-soft.com>
From: <Rishabh@soc-soft.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
I am working out the possibility of implementing HIGHMEM support for
MIPS architecture in Linux 2.6.10 kernel. For Linux 2.4 kernel this
support was not available, eventhough there is a specific kernel
configuration to enable HIGHMEM and no such option is available in 2.6
kernel.

Is it possible to implement HIGHMEM as I want to put 1GB RAM to my MIPS
board. Also are there any performance issues and other goof-ups in
implementing the same.

Where can I find documentation for the same?


Regards,
Rishabh






The information contained in this e-mail message and in any annexure is
confidential to the  recipient and may contain privileged information. If you are not
the intended recipient, please notify the sender and delete the message along with
any annexure. You should not disclose, copy or otherwise use the information contained
in the message or any annexure. Any views expressed in this e-mail are those of the
individual sender except where the sender specifically states them to be the views of
SoCrates Software India Pvt Ltd., Bangalore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

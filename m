Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.0.10])
	by anchor-post-30.mail.demon.net with esmtp (Exim 4.42)
	id 1GWxpf-0000Wd-1U
	for linux-mm@kvack.org; Mon, 09 Oct 2006 16:18:33 +0000
Message-ID: <452A764F.2010609@superbug.demon.co.uk>
Date: Mon, 09 Oct 2006 17:18:23 +0100
From: James Courtier-Dutton <James@superbug.demon.co.uk>
MIME-Version: 1.0
Subject: Prevent self modifying code.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

1) In linux, is it possible to enforce that all pages with executable
program code are automatically marked read-only? I.e. to actively
prevent any self modifying code.
2) I know there is a NX(no execute) bit. Is that automatically applied
to all read-write pages? i.e to stack and data pages.
3) Is it possible to ensure that the kernel is the only place that can
take files with the +x bit set, and load the program code into memory
then mark it as read-only, executable pages.
4) Is it possible to ensure that all jump tables used by the executable
code are also read-only?

James




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from fenrus.demon.nl (mail@fenrus.demon.nl [212.238.78.16])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA05226
	for <linux-mm@kvack.org>; Sun, 30 May 1999 11:21:12 -0400
Date: Sun, 30 May 1999 17:20:58 +0200 (CEST)
From: Arjan van de Ven <arjan@fenrus.demon.nl>
Subject: Export do_generic_file_read
Message-ID: <Pine.LNX.4.05.9905301719180.988-100000@fenrus.demon.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Is there a special reason for not exporting do_generic_file_read from
mm/filemap.c? I would like to use it in a module to make a "sendfile from
struct file to struct socket". (I hope this helps for my kernel-httpd).

Greetings,
  Arjan van de Ven

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

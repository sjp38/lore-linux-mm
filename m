Received: from localhost (riel@localhost)
	by brutus.conectiva.com.br (8.11.2/8.11.2) with ESMTP id f27GAPU24272
	for <linux-mm@kvack.org>; Wed, 7 Mar 2001 13:10:29 -0300
Content-Type: text/plain;
  charset="iso-8859-1"
From: =?iso-8859-1?q?Jos=E9=20Manuel=20Rom=E1n=20Ram=EDrez?=
        <uzi@xerxes.conectiva.com.br>
Subject: Bug? in 2.4 memory management...
Date: Wed, 7 Mar 2001 12:33:36 +0100
MIME-Version: 1.0
Message-Id: <01030712333600.03019@xerxes>
Content-Transfer-Encoding: 8bit
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0103071310200.1409@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi,
I think we've 'discovered' a bug regarding the kernel 2.4.2-ac11 (and maybe 
other) and the memory management. It seems that the cached memory sometimes 
is not freed as more memory is required. 

The system where we have detected the problem was an athlon 1ghz, 1.2gb of 
ram, and a swapfile of 2gb.

When we run a program that requires/uses 1ghz of memory, and we kill it, all 
(or nearly all) the memory is used by the cache, as we load a hugue file. The 
next time we run the program, it seems like the kernel can't use the cached 
memory and the memory we need is taken from the swap. Note however that when 
we set a swap partition smaller than the memory required, let's say 128mb, 
the problem disappears as the cache memory is used instead the swap...

So, what's wrong? Thanks in advance!

-- 
"I consider Red Hat 7.0 to be basically unusable as a development platform"
Linus Torvalds
--
Jose Manuel Roman - Theuzifan
roman@wol.es - uzi@simauria.upv.es

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

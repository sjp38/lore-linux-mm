Date: Mon, 27 Aug 2001 23:54:54 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Testers needed for 2.4 highmem IO
Message-ID: <Pine.LNX.4.21.0108272344140.7602-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

I need people with access to highmem machines (8GB or more) to test a
patch which should fix the current allocation failure problems under IO
stress with 2.4.10pre1.

Just stress the IO subsystem with huge amounts of data ( > 2x amount of
memory). Several threads doing the IO is preferred.

Patch at
http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.10pre1/highio.patch

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: from ttb by platypus.tentacle.dhs.org with local (Exim 3.12 #1 (Debian))
	id 13XXRq-0008GN-00
	for <linux-mm@kvack.org>; Fri, 08 Sep 2000 19:20:42 -0400
Date: Fri, 8 Sep 2000 19:20:42 -0400
From: deprogrammer <ttb@tentacle.dhs.org>
Subject: test8-vmpatch performs great here!
Message-ID: <20000908192042.A31685@tentacle.dhs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


After reading ben's email I dicided to run his same test on my box
running test8 + vmpatch3 

some specs: K7 - 600, 128MB ram.

environment: X 4.0.1 and netscape 4.75 were running.

I ran 2 tests:
	1) tar zxvf linux-2.4.0-test6.tar.gz
	2) tar xvf linux-2.4.0-test6.tar


free_before:
	total       used       free     shared    buffers     cached
	Mem:        127176      62960      64216          0       2164      25500
	-/+ buffers/cache:      35296      91880
	Swap:       128516          0     128516

free_after_tgz:
	total       used       free     shared    buffers     cached
	Mem:        127176     124892       2284          0       6612      80592
	-/+ buffers/cache:      37688      89488
	Swap:       128516          0     128516

free_after_tar:
total       used       free     shared    buffers     cached
Mem:        127176     124952       2224          0       2848      85336
-/+ buffers/cache:      36768      90408
Swap:       128516          0     128516

The box remained somewhat interactive, but a few times during the tar zxvf the
box would stop responding for a few seconds during which there would be alot
of disk activity, same for the tar xvf.

john
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

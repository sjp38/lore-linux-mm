Received: from NigelLaptop
 (203-167-153-172.dialup.clear.net.nz [203.167.153.172])
 by smtp2.clear.net.nz (CLEAR Net Mail)
 with SMTP id <0H6Y00F8F05GNM@smtp2.clear.net.nz> for linux-mm@kvack.org; Wed,
 11 Dec 2002 19:46:29 +1300 (NZDT)
Date: Wed, 11 Dec 2002 19:44:29 +1300
From: Nigel Cunningham <ncunningham@clear.net.nz>
Subject: Using reverse mapping in 2.5.51 for suspend-to-disk.
Message-id: <000101c2a0e0$c5743140$ac99a7cb@NigelLaptop>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Linux Memory Management List (E-mail)" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all.

Let me begin by saying I'm quite new to kernel hacking, and will freely
admit that I've lots still to learn. Please, therefore, cut me some slack if
I show previously unsurpassed ignorance!

First, some background:

I've done some work on the suspend-to-disk code in the 2.4 series kernels.
The mainstream suspend-to-disk code in 2.4 essentially eats all the memory
it can, makes a copy of the remainder, and writes that copy to disk. I
prepared a version that eats far less memory and writes a bigger image,
thereby resulting in a more responsive system on resume (although it takes
longer to read). The target, of course is to eat [virtually] no memory at
all and store as close to a perfect image as possible. To get closer to
that, I implemented a crude reverse mapping (assuming I understand the term
correctly) which makes a bitmap of pages ('pageset 1') that are only used by
processes which have been stopped (ie processes not needed for writing the
image), writes the contents of those pages to disk and then copies and saves
the remaining pages ('pageset 2') using pageset1 pages and free memory. It
works well, and will probably work better once I put it in a kernel where
drivers are properly quiesced!

Which brings me to my question. I want to start trying to get this going in
a 2.5 kernel, and have seen people talking about reverse-mapping patches for
a while now. I'm wondering if you have managed or are preparing to merge
such patches into the 2.5 series, whether they would be helpful to me in
identifying those pageset1 pages. If so, how I use them.

Of course you might want to bag the whole method in general :> I'll happily
try to implement a better method if you suggestion one!

Regards and thanks in advance,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

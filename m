Received: from indyio.rz.uni-sb.de (indyio.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA23263
	for <linux-mm@kvack.org>; Thu, 29 Apr 1999 10:21:33 -0400
Message-ID: <3729BC27.3087E751@colorfullife.com>
Date: Fri, 30 Apr 1999 16:20:23 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: Hello
References: <v04020a01b34cd7f3c7c3@[198.115.92.60]>
Content-Type: multipart/mixed;
 boundary="------------8AE0BBCF6C1587E0B09B45D4"
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "James E. King, III" <jking@ariessys.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8AE0BBCF6C1587E0B09B45D4
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

"James E. King, III" wrote:
> 2. Can I create a large (let's say 1GB) ramdisk or memory filesystem?

Is there any reason why rd_size can only be set at system startup,
but not if rd is loaded as a module?

I personally use the attached patch without any problems.

Regards,
	Manfred
--------------8AE0BBCF6C1587E0B09B45D4
Content-Type: application/octet-stream;
 name="patch_rd_size-2.2.6"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patch_rd_size-2.2.6"

LS0tIDIuMi42L2RyaXZlcnMvYmxvY2svcmQuYwlXZWQgQXByIDI4IDE4OjEzOjU5IDE5OTkK
KysrIGN1cnJlbnQvZHJpdmVycy9ibG9jay9yZC5jCUZyaSBBcHIgMzAgMTU6NTk6MjYgMTk5
OQpAQCAtMTAwLDYgKzEwMCw5IEBACiAgKi8KIGludCByZF9zaXplID0gNDA5NjsJCS8qIFNp
emUgb2YgdGhlIFJBTSBkaXNrcyAqLwogCisjaWZkZWYgTU9EVUxFCitNT0RVTEVfUEFSTShy
ZF9zaXplLCJpIik7CisjZW5kaWYKICNpZm5kZWYgTU9EVUxFCiBpbnQgcmRfZG9sb2FkID0g
MDsJCS8qIDEgPSBsb2FkIFJBTSBkaXNrLCAwID0gZG9uJ3QgbG9hZCAqLwogaW50IHJkX3By
b21wdCA9IDE7CQkvKiAxID0gcHJvbXB0IGZvciBSQU0gZGlzaywgMCA9IGRvbid0IHByb21w
dCAqLwo=
--------------8AE0BBCF6C1587E0B09B45D4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

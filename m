Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA23647
	for <linux-mm@kvack.org>; Sat, 11 Jul 1998 03:33:18 -0400
Date: Sat, 11 Jul 1998 09:31:26 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] stricter pagecache pruning
Message-ID: <Pine.LNX.3.96.980711092706.5292B-200000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="655616-1112206315-900142286=:5292"
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--655616-1112206315-900142286=:5292
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

I hope this patch will alleviate some of Andrea's
problems with the page cache growing out of bounds.

It makes sure that, when the cache uses too much,
shrink_mmap() is called continuously; only the
last thing tried can be something else.

I'd like to hear some results, as I haven't tried
it myself ... It seems obvious enough, so it would
probably be best if it's tried ASAP with as many
different machines/loads as possible.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--655616-1112206315-900142286=:5292
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="borrow-108.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.3.96.980711093126.5292C@mirkwood.dummy.home>
Content-Description: mmap-prune-2.1.108.patch

LS0tIGxpbnV4L21tL3Ztc2Nhbi5jLm9yaWcJU2F0IEp1bCAxMSAwOToxMzoz
NyAxOTk4DQorKysgbGludXgvbW0vdm1zY2FuLmMJU2F0IEp1bCAxMSAwOToy
NjoxOCAxOTk4DQpAQCAtNDQ4LDcgKzQ0OCw3IEBADQogew0KIAlzdGF0aWMg
aW50IHN0YXRlID0gMDsNCiAJaW50IGk9NjsNCi0JaW50IHN0b3A7DQorCWlu
dCBzdG9wLCBzaHJpbmsgPSAwOw0KIA0KIAkvKiBBbHdheXMgdHJpbSBTTEFC
IGNhY2hlcyB3aGVuIG1lbW9yeSBnZXRzIGxvdy4gKi8NCiAJa21lbV9jYWNo
ZV9yZWFwKGdmcF9tYXNrKTsNCkBAIC00NTgsMTQgKzQ1OCwxOSBAQA0KIAlp
ZiAoZ2ZwX21hc2sgJiBfX0dGUF9XQUlUKQ0KIAkJc3RvcCA9IDA7DQogCWlm
ICgoKGJ1ZmZlcm1lbSA+PiBQQUdFX1NISUZUKSAqIDEwMCA+IGJ1ZmZlcl9t
ZW0uYm9ycm93X3BlcmNlbnQgKiBudW1fcGh5c3BhZ2VzKQ0KLQkJICAgfHwg
KHBhZ2VfY2FjaGVfc2l6ZSAqIDEwMCA+IHBhZ2VfY2FjaGUuYm9ycm93X3Bl
cmNlbnQgKiBudW1fcGh5c3BhZ2VzKSkNCisJCSAgIHx8IChwYWdlX2NhY2hl
X3NpemUgKiAxMDAgPiBwYWdlX2NhY2hlLmJvcnJvd19wZXJjZW50ICogbnVt
X3BoeXNwYWdlcykpIHsNCiAJCXN0YXRlID0gMDsNCisJCXNocmluayA9IGkg
LSBzdG9wOw0KKwl9DQogDQogCXN3aXRjaCAoc3RhdGUpIHsNCiAJCWRvIHsN
CiAJCWNhc2UgMDoNCi0JCQlpZiAoc2hyaW5rX21tYXAoaSwgZ2ZwX21hc2sp
KQ0KLQkJCQlyZXR1cm4gMTsNCisJCQlkbyB7DQorCQkJCWlmIChzaHJpbmtf
bW1hcChpLCBnZnBfbWFzaykpDQorCQkJCQlyZXR1cm4gMTsNCisJCQkJaWYg
KHNocmluaykgc2hyaW5rLS07DQorCQkJfSB3aGlsZSAoc2hyaW5rKTsNCiAJ
CQlzdGF0ZSA9IDE7DQogCQljYXNlIDE6DQogCQkJaWYgKChnZnBfbWFzayAm
IF9fR0ZQX0lPKSAmJiBzaG1fc3dhcChpLCBnZnBfbWFzaykpDQo=
--655616-1112206315-900142286=:5292--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

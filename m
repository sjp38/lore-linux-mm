Date: Mon, 9 Oct 2000 22:13:28 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010092211310.8045-200000@elte.hu>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="655616-910961921-971122408=:8045"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--655616-910961921-971122408=:8045
Content-Type: TEXT/PLAIN; charset=US-ASCII


Rik,

what do you think about the attached patch? It increases the effective
priority of a (kernel-) killed process, and initiates a reschedule, so
that it gets selected ASAP. (except if there are RT processes around.)
This should make OOM decisions 'visible' much more quickly.

	Ingo

--655616-910961921-971122408=:8045
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="kill-2.4.0-test9-A0"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0010092213280.8045@elte.hu>
Content-Description: 
Content-Disposition: attachment; filename="kill-2.4.0-test9-A0"

LS0tIGxpbnV4L2tlcm5lbC9zaWduYWwuYy5vcmlnCU1vbiBPY3QgIDkgMTI6
NTY6NDUgMjAwMA0KKysrIGxpbnV4L2tlcm5lbC9zaWduYWwuYwlNb24gT2N0
ICA5IDEzOjAwOjIwIDIwMDANCkBAIC01NjksNiArNTY5LDE0IEBADQogCQlz
cGluX3VubG9ja19pcnFyZXN0b3JlKCZ0LT5zaWdtYXNrX2xvY2ssIGZsYWdz
KTsNCiAJCXJldHVybiAtRVNSQ0g7DQogCX0NCisJLyoNCisJICogU3BlY2lh
bCBjYXNlLCBrZXJuZWwgaXMgZm9yY2luZyBTSUdLSUxMLg0KKwkgKiBEZWNy
ZWFzZSBzaWduYWwgZGVsaXZlcnkgbGF0ZW5jeS4NCisJICovDQorCWlmIChz
aWcgPT0gU0lHS0lMTCAmJiAodC0+cG9saWN5ID09IFNDSEVEX09USEVSKSkg
ew0KKwkJdC0+Y291bnRlciA9IE1BWF9DT1VOVEVSOw0KKwkJY3VycmVudC0+
bmVlZF9yZXNjaGVkID0gMTsNCisJfQ0KIA0KIAlpZiAodC0+c2lnLT5hY3Rp
b25bc2lnLTFdLnNhLnNhX2hhbmRsZXIgPT0gU0lHX0lHTikNCiAJCXQtPnNp
Zy0+YWN0aW9uW3NpZy0xXS5zYS5zYV9oYW5kbGVyID0gU0lHX0RGTDsNCg==
--655616-910961921-971122408=:8045--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

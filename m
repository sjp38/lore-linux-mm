Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EAAA76B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 22:15:25 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so5898332pac.25
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 19:15:25 -0800 (PST)
Received: from mx1.mxmail.xiaomi.com ([58.68.235.87])
        by mx.google.com with ESMTP id fs12si7458328pdb.56.2014.11.27.19.15.23
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 19:15:24 -0800 (PST)
From: =?gb2312?B?1uy71A==?= <zhuhui@xiaomi.com>
Subject: CMA, isolate: get warning in page_isolation.c:235 test_pages_isolated
Date: Fri, 28 Nov 2014 03:15:19 +0000
Message-ID: <1417144515812.18416@xiaomi.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "weijie.yang@samsung.com" <weijie.yang@samsung.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>
Cc: Hui Zhu <teawater@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

SGkgZ3V5cywKCkFmdGVyIEkgYmFjayBwb3J0aW5nIHlvdXIgcGF0Y2hlczoKbW0vcGFnZV9hbGxv
YzogZml4IGluY29ycmVjdCBpc29sYXRpb24gYmVoYXZpb3IgYnkgcmVjaGVja2luZyBtaWdyYXRl
dHlwZQptbS9wYWdlX2FsbG9jOiBhZGQgZnJlZXBhZ2Ugb24gaXNvbGF0ZSBwYWdlYmxvY2sgdG8g
Y29ycmVjdCBidWRkeSBsaXN0Cm1tL3BhZ2VfYWxsb2M6IG1vdmUgZnJlZXBhZ2UgY291bnRpbmcg
bG9naWMgdG8gX19mcmVlX29uZV9wYWdlKCkKbW0vcGFnZV9hbGxvYzogcmVzdHJpY3QgbWF4IG9y
ZGVyIG9mIG1lcmdpbmcgb24gaXNvbGF0ZWQgcGFnZWJsb2NrCm1tOiBwYWdlX2FsbG9jOiBzdG9y
ZSB1cGRhdGVkIHBhZ2UgbWlncmF0ZXR5cGUgdG8gYXZvaWQgbWlzdXNpbmcgc3RhbGUgdmFsdWUK
bW06IHBhZ2VfaXNvbGF0aW9uOiBjaGVjayBwZm4gdmFsaWRpdHkgYmVmb3JlIGFjY2Vzcwp0byAz
LjEwIGxpbnV4IGtlcm5lbC4KSSBhbHNvIHVzZSB0aGUgQ01BX0FHR1JFU1NJVkUgcGF0Y2hlcyBp
biBodHRwczovL2xrbWwub3JnL2xrbWwvMjAxNC8xMC8xNS82MjMuCgpJIGdvdDoKWzY4MTIxLjc3
MDY5OUAyXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWzY4MTIxLjc3NDU5
MkAyXSBXQVJOSU5HOiBhdCAvaG9tZS90ZWF3YXRlci9jb21tb24vbW0vcGFnZV9pc29sYXRpb24u
YzoyMzUgdGVzdF9wYWdlc19pc29sYXRlZCsweDEwOC8weDIwOCgpCls2ODEyMS43OTM5MTFAMl0g
Q1BVOiAyIFBJRDogMjcxMSBDb21tOiBrdGhyZWFkX3h4eCBUYWludGVkOiBQICAgICAgICAgICBP
IDMuMTAuMzMtMjUwNjQ0LWdjZmQ5M2Y4LWRpcnR5ICMxODQKWzY4MTIxLjgwMzYzMkAyXSBbPGMw
MDE2ZGU0Pl0gKHVud2luZF9iYWNrdHJhY2UrMHgwLzB4MTI4KSBmcm9tIFs8YzAwMTMzNjA+XSAo
c2hvd19zdGFjaysweDIwLzB4MjQpCls2ODEyMS44MTIzNzlAMl0gWzxjMDAxMzM2MD5dIChzaG93
X3N0YWNrKzB4MjAvMHgyNCkgZnJvbSBbPGMwNzQ1NTNjPl0gKGR1bXBfc3RhY2srMHgyMC8weDI4
KQpbNjgxMjEuODIwNjEyQDJdIFs8YzA3NDU1M2M+XSAoZHVtcF9zdGFjaysweDIwLzB4MjgpIGZy
b20gWzxjMDAyZjJiOD5dICh3YXJuX3Nsb3dwYXRoX2NvbW1vbisweDVjLzB4N2MpCls2ODEyMS44
Mjk3MTJAMl0gWzxjMDAyZjJiOD5dICh3YXJuX3Nsb3dwYXRoX2NvbW1vbisweDVjLzB4N2MpIGZy
b20gWzxjMDAyZjMwND5dICh3YXJuX3Nsb3dwYXRoX251bGwrMHgyYy8weDM0KQpbNjgxMjEuODM5
NTA4QDJdIFs8YzAwMmYzMDQ+XSAod2Fybl9zbG93cGF0aF9udWxsKzB4MmMvMHgzNCkgZnJvbSBb
PGMwMTFmMzI0Pl0gKHRlc3RfcGFnZXNfaXNvbGF0ZWQrMHgxMDgvMHgyMDgpCls2ODEyMS44NDkz
OTNAMl0gWzxjMDExZjMyND5dICh0ZXN0X3BhZ2VzX2lzb2xhdGVkKzB4MTA4LzB4MjA4KSBmcm9t
IFs8YzAwZTI0ZDg+XSAoYWxsb2NfY29udGlnX3JhbmdlKzB4MjA4LzB4MmIwKQpbNjgxMjEuODU5
NDQ3QDJdIFs8YzAwZTI0ZDg+XSAoYWxsb2NfY29udGlnX3JhbmdlKzB4MjA4LzB4MmIwKSBmcm9t
IFs8YzAzMjBkNDQ+XSAoZG1hX2FsbG9jX2Zyb21fY29udGlndW91cysweDE1Yy8weDI0YykKCkxv
b2tzIGl0IGhhcyBzb21lIHJhY2UgaXNzdWUgYmV0d2VlbiBwYWdlIGlzb2xhdGlvbiBhbmQgZnJl
ZSBwYXRoIGFmdGVyIHRoZXNlIHBhdGNoZXMuCkFuZCBJIGNoZWNrZWQgdGhlIGZyZWUgcGF0aCBi
dXQgZm91bmQgbm90aGluZy4KCkkgd29ycmllZCB0aGF0IGl0IHN0aWxsIGhhcyBzb21lIHJhY2Ug
aXNzdWUgYmV0d2VlbiBwYWdlIGlzb2xhdGlvbiBhbmQgc29tZXRoaW5nIGluIHVwc3RyZWFtLiAg
T3IgSSBtaXNzZWQgc29tZSBwYXRjaGVzPwpJZiB3ZSBjYW5ub3QgaGFuZGxlIHRoaXMgaXNzdWUg
aW4gYSBzaG9ydCB0aW1lLCBJIHN1Z2dlc3QgYWRkIHRoZSAibW92ZV9mcmVlcGFnZXMiIGNvZGUg
YmFjayB0byBfX3Rlc3RfcGFnZV9pc29sYXRlZF9pbl9wYWdlYmxvY2suCgpUaGFua3MsCkh1aQoK
IA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

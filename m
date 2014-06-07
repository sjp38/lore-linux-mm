Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E9CB56B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 08:35:27 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so3594880pbb.36
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 05:35:27 -0700 (PDT)
Received: from mail2-185.sinamail.sina.com.cn ([60.28.2.185])
        by mx.google.com with ESMTP id el5si25051911pbc.217.2014.06.07.05.35.25
        for <linux-mm@kvack.org>;
        Sat, 07 Jun 2014 05:35:27 -0700 (PDT)
Date: Sat, 07 Jun 2014 20:35:18 +0800 
Reply-To: zhdxzx@sina.com
From: <zhdxzx@sina.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
MIME-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Message-Id: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felipe Contreras <felipe.contreras@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, dhillf <dhillf@gmail.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>

LS0tLS0gT3JpZ2luYWwgTWVzc2FnZSAtLS0tLQ0KRnJvbTogRmVsaXBlIENvbnRyZXJhcyA8ZmVs
aXBlLmNvbnRyZXJhc0BnbWFpbC5jb20+DQoNCj4+T24gRnJpLCBKdW4gNiwgMjAxNCBhdCA0OjU4
IEFNLCAgPHpoZHh6eEBzaW5hLmNvbT4gd3JvdGU6DQo+PiBBbHRlcm5hdGl2ZWx5IGNhbiB3ZSB0
cnkgd2FpdF9pZmZfY29uZ2VzdGVkKHpvbmUsIEJMS19SV19BU1lOQywgSFovMTApID8NCj4+DQo+
IEkgc2VlIHRoZSBzYW1lIHByb2JsZW0gd2l0aCB0aGF0IGNvZGUuDQo+DQpUaGUgY29tbWVudHMg
YXJvdW5kIHRoZSBjb25nZXN0aW9uX3dhaXQsDQpbMV0NCgkgKg0KCSAqIE9uY2UgYSB6b25lIGlz
IGZsYWdnZWQgWk9ORV9XUklURUJBQ0ssIGtzd2FwZCB3aWxsIGNvdW50IHRoZSBudW1iZXINCgkg
KiBvZiBwYWdlcyB1bmRlciBwYWdlcyBmbGFnZ2VkIGZvciBpbW1lZGlhdGUgcmVjbGFpbSBhbmQg
c3RhbGwgaWYgYW55DQoJICogYXJlIGVuY291bnRlcmVkIGluIHRoZSBucl9pbW1lZGlhdGUgY2hl
Y2sgYmVsb3cuDQoJICovDQoJaWYgKG5yX3dyaXRlYmFjayAmJiBucl93cml0ZWJhY2sgPT0gbnJf
dGFrZW4pDQoJCXpvbmVfc2V0X2ZsYWcoem9uZSwgWk9ORV9XUklURUJBQ0spOw0KDQoNClsyXQ0K
CQkvKg0KCQkgKiBJZiBkaXJ0eSBwYWdlcyBhcmUgc2Nhbm5lZCB0aGF0IGFyZSBub3QgcXVldWVk
IGZvciBJTywgaXQNCgkJICogaW1wbGllcyB0aGF0IGZsdXNoZXJzIGFyZSBub3Qga2VlcGluZyB1
cC4gSW4gdGhpcyBjYXNlLCBmbGFnDQoJCSAqIHRoZSB6b25lIFpPTkVfVEFJTF9MUlVfRElSVFkg
YW5kIGtzd2FwZCB3aWxsIHN0YXJ0IHdyaXRpbmcNCgkJICogcGFnZXMgZnJvbSByZWNsYWltIGNv
bnRleHQuIEl0IHdpbGwgZm9yY2libHkgc3RhbGwgaW4gdGhlDQoJCSAqIG5leHQgY2hlY2suDQoJ
CSAqLw0KCQlpZiAobnJfdW5xdWV1ZWRfZGlydHkgPT0gbnJfdGFrZW4pDQoJCQl6b25lX3NldF9m
bGFnKHpvbmUsIFpPTkVfVEFJTF9MUlVfRElSVFkpOw0KDQpUaGUgImZvcmNlIHN0YWxsIiBpbiBb
Ml0gY29uZmxpY3RzIHdpdGggInN0YXJ0IHdyaXRpbmcgcGFnZXMiIGluIFsyXSwgYW5kDQpjb25m
bGljdHMgd2l0aCAibnJfaW1tZWRpYXRlIGNoZWNrIGJlbG93IiBpbiBbMV0gYXMgd2VsbCwgSUlV
Qy4NCg0KV291bGQgeW91IHBsZWFzZSB0cnkgYWdhaW4gYmFzZWQgb25seSBvbiBjb21tZW50IFsx
XShiYXNlZCBvbiB2My4xNS1yYzgpPw0KdGhhbmtzDQpIaWxsZg0KDQotLS0gYS9tbS92bXNjYW4u
YwlTYXQgSnVuICA3IDE4OjM4OjA4IDIwMTQNCisrKyBiL21tL3Ztc2Nhbi5jCVNhdCBKdW4gIDcg
MjA6MDg6MzYgMjAxNA0KQEAgLTE1NjYsNyArMTU2Niw3IEBAIHNocmlua19pbmFjdGl2ZV9saXN0
KHVuc2lnbmVkIGxvbmcgbnJfdG8NCiAJCSAqIGltcGxpZXMgdGhhdCBwYWdlcyBhcmUgY3ljbGlu
ZyB0aHJvdWdoIHRoZSBMUlUgZmFzdGVyIHRoYW4NCiAJCSAqIHRoZXkgYXJlIHdyaXR0ZW4gc28g
YWxzbyBmb3JjaWJseSBzdGFsbC4NCiAJCSAqLw0KLQkJaWYgKG5yX3VucXVldWVkX2RpcnR5ID09
IG5yX3Rha2VuIHx8IG5yX2ltbWVkaWF0ZSkNCisJCWlmIChucl9pbW1lZGlhdGUpDQogCQkJY29u
Z2VzdGlvbl93YWl0KEJMS19SV19BU1lOQywgSFovMTApOw0KIAl9DQogDQotLQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

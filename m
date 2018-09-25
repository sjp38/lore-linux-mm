Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 681918E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 10:13:16 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e88-v6so8772371qtb.1
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 07:13:16 -0700 (PDT)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id v11-v6si1774456qvi.252.2018.09.25.07.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 07:13:15 -0700 (PDT)
From: "Stecklina, Julian" <jsteckli@amazon.de>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Date: Tue, 25 Sep 2018 14:12:57 +0000
Message-ID: <1537884777.23693.27.camel@amazon.de>
References: <20180820212556.GC2230@char.us.oracle.com>
	 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
	 <1534801939.10027.24.camel@amazon.co.uk> <20180919010337.GC8537@350D>
	 <CA+VK+GM6CaPnGKcPjEn7U=4ubtC-JWZ9k98BTxzRH_TthaFXDw@mail.gmail.com>
	 <20180923023315.GF8537@350D>
In-Reply-To: <20180923023315.GF8537@350D>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F4BF4A3594F63541B0C088C51CAE7501@amazon.com>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jwadams@google.com" <jwadams@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>
Cc: "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "keescook@google.com" <keescook@google.com>, "jsteckli@os.inf.tu-dresden.de" <jsteckli@os.inf.tu-dresden.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

T24gU3VuLCAyMDE4LTA5LTIzIGF0IDEyOjMzICsxMDAwLCBCYWxiaXIgU2luZ2ggd3JvdGU6DQo+
ID4gQW5kIGluIHNvIGRvaW5nLCBzaWduaWZpY2FudGx5IHJlZHVjZXMgdGhlIGFtb3VudCBvZiBu
b24ta2VybmVsDQo+IGRhdGENCj4gPiB2dWxuZXJhYmxlIHRvIHNwZWN1bGF0aXZlIGV4ZWN1dGlv
biBhdHRhY2tzIGFnYWluc3QgdGhlIGtlcm5lbC4NCj4gPiAoYW5kIHJlZHVjZXMgd2hhdCBkYXRh
IGNhbiBiZSBsb2FkZWQgaW50byB0aGUgTDEgZGF0YSBjYWNoZSB3aGlsZQ0KPiA+IGluIGtlcm5l
bCBtb2RlLCB0byBiZSBwZWVrZWQgYXQgYnkgdGhlIHJlY2VudCBMMSBUZXJtaW5hbCBGYXVsdA0K
PiA+IHZ1bG5lcmFiaWxpdHkpLg0KPiANCj4gSSBzZWUgYW5kIHRoZXJlIGlzIG5vIHdheSBmb3Ig
Z2FkZ2V0cyB0byBpbnZva2UgdGhpcyBwYXRoIGZyb20NCj4gdXNlciBzcGFjZSB0byBtYWtlIHRo
ZWlyIHNwZWN1bGF0aW9uIHN1Y2Nlc3NmdWw/IFdlIHN0aWxsIGhhdmUgdG8NCj4gZmx1c2ggTDEs
IGluZGVwZW5lZGVudCBvZiB3aGV0aGVyIFhQRk8gaXMgZW5hYmxlZCBvciBub3QgcmlnaHQ/DQoN
Clllcy4gQW5kIGV2ZW4gd2l0aCBYUEZPIGFuZCBMMSBjYWNoZSBmbHVzaGluZyBlbmFibGVkLCB0
aGVyZSBhcmUgbW9yZQ0Kc3RlcHMgdGhhdCBuZWVkIHRvIGJlIHRha2VuIHRvIHJlbGlhYmx5IGd1
YXJkIGFnYWluc3QgaW5mb3JtYXRpb24gbGVha3MNCnVzaW5nIHNwZWN1bGF0aXZlIGV4ZWN1dGlv
bi4NCg0KU3BlY2lmaWNhbGx5LCBJJ20gbG9va2luZyBpbnRvIG1ha2luZyBjZXJ0YWluIGFsbG9j
YXRpb25zIGluIHRoZSBMaW51eA0Ka2VybmVsIHByb2Nlc3MtbG9jYWwgdG8gaGlkZSBldmVuIG1v
cmUgbWVtb3J5IGZyb20gcHJlZmV0Y2hpbmcuDQoNCkFub3RoZXIgcHV6emxlIHBpZWNlIGlzIGNv
LXNjaGVkdWxpbmcgc3VwcG9ydCB0aGF0IGlzIHJlbGV2YW50IGZvcg0Kc3lzdGVtcyB3aXRoIGVu
YWJsZWQgaHlwZXJ0aHJlYWRpbmc6wqBodHRwczovL2x3bi5uZXQvQXJ0aWNsZXMvNzY0NDYxLw0K
DQpKdWxpYW4KQW1hem9uIERldmVsb3BtZW50IENlbnRlciBHZXJtYW55IEdtYkgKQmVybGluIC0g
RHJlc2RlbiAtIEFhY2hlbgptYWluIG9mZmljZTogS3JhdXNlbnN0ci4gMzgsIDEwMTE3IEJlcmxp
bgpHZXNjaGFlZnRzZnVlaHJlcjogRHIuIFJhbGYgSGVyYnJpY2gsIENocmlzdGlhbiBTY2hsYWVn
ZXIKVXN0LUlEOiBERTI4OTIzNzg3OQpFaW5nZXRyYWdlbiBhbSBBbXRzZ2VyaWNodCBDaGFybG90
dGVuYnVyZyBIUkIgMTQ5MTczIEIK

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA088E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:46:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l11-v6so22538978qkk.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:46:00 -0700 (PDT)
Received: from smtp-fw-9101.amazon.com (smtp-fw-9101.amazon.com. [207.171.184.25])
        by mx.google.com with ESMTPS id j12-v6si2669454qvo.267.2018.09.24.07.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 07:45:59 -0700 (PDT)
From: "Stecklina, Julian" <jsteckli@amazon.de>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Date: Mon, 24 Sep 2018 14:45:41 +0000
Message-ID: <1537800341.9745.20.camel@amazon.de>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
	 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
	 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
	 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
	 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
	 <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
	 <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
	 <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
In-Reply-To: <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D5DA42683F56B14396B5512A9BB52777@amazon.com>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>
Cc: "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "keescook@google.com" <keescook@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

T24gVHVlLCAyMDE4LTA5LTE4IGF0IDE3OjAwIC0wNjAwLCBLaGFsaWQgQXppeiB3cm90ZToNCj4g
SSB0ZXN0ZWQgdGhlIGtlcm5lbCB3aXRoIHRoaXMgbmV3IGNvZGUuIFdoZW4gYm9vdGVkIHdpdGhv
dXQNCj4gInhwZm90bGJmbHVzaCIswqANCj4gdGhlcmUgaXMgbm8gbWVhbmluZ2Z1bCBjaGFuZ2Ug
aW4gc3lzdGVtIHRpbWUgd2l0aCBrZXJuZWwgY29tcGlsZS4gDQoNClRoYXQncyBnb29kIG5ld3Mh
IFNvIHRoZSBsb2NrIG9wdGltaXphdGlvbnMgc2VlbSB0byBoZWxwLg0KDQo+IEtlcm5lbMKgDQo+
IGxvY2tzIHVwIGR1cmluZyBib290dXAgd2hlbiBib290ZWQgd2l0aCB4cGZvdGxiZmx1c2g6DQoN
CkkgZGlkbid0IHRlc3QgdGhlIHZlcnNpb24gd2l0aCBUTEIgZmx1c2hlcywgYmVjYXVzZSBpdCdz
IGNsZWFyIHRoYXQgdGhlDQpvdmVyaGVhZCBpcyBzbyBiYWQgdGhhdCBubyBvbmUgd2FudHMgdG8g
dXNlIHRoaXMuDQoNCkl0IHNob3VsZG4ndCBsb2NrIHVwIHRob3VnaCwgc28gbWF5YmUgdGhlcmUg
aXMgc3RpbGwgYSByYWNlIGNvbmRpdGlvbg0Kc29tZXdoZXJlLiBJJ2xsIGdpdmUgdGhpcyBhIHNw
aW4gb24gbXkgZW5kIGxhdGVyIHRoaXMgd2Vlay4NCg0KVGhhbmtzIGZvciB0cnlpbmcgdGhpcyBv
dXQhDQoNCkp1bGlhbg0KQW1hem9uIERldmVsb3BtZW50IENlbnRlciBHZXJtYW55IEdtYkgKQmVy
bGluIC0gRHJlc2RlbiAtIEFhY2hlbgptYWluIG9mZmljZTogS3JhdXNlbnN0ci4gMzgsIDEwMTE3
IEJlcmxpbgpHZXNjaGFlZnRzZnVlaHJlcjogRHIuIFJhbGYgSGVyYnJpY2gsIENocmlzdGlhbiBT
Y2hsYWVnZXIKVXN0LUlEOiBERTI4OTIzNzg3OQpFaW5nZXRyYWdlbiBhbSBBbXRzZ2VyaWNodCBD
aGFybG90dGVuYnVyZyBIUkIgMTQ5MTczIEIK

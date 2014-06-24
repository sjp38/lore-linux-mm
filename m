Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D12966B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 01:58:12 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so6528185pdi.23
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 22:58:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nx10si24712682pbb.197.2014.06.23.22.58.11
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 22:58:11 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Date: Tue, 24 Jun 2014 05:53:46 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com>
 <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com>
 <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com>
 <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
In-Reply-To: <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

T24gMjAxNC0wNi0yNCwgQW5keSBMdXRvbWlyc2tpIHdyb3RlOg0KPj4gT24gMDYvMjMvMjAxNCAw
MTowNiBQTSwgQW5keSBMdXRvbWlyc2tpIHdyb3RlOg0KPj4+IENhbiB0aGUgbmV3IHZtX29wZXJh
dGlvbiAibmFtZSIgYmUgdXNlIGZvciB0aGlzPyAgVGhlIG1hZ2ljICJhbHdheXMNCj4+PiB3cml0
dGVuIHRvIGNvcmUgZHVtcHMiIGZlYXR1cmUgbWlnaHQgbmVlZCB0byBiZSByZWNvbnNpZGVyZWQu
DQo+PiANCj4+IE9uZSB0aGluZyBJJ2QgbGlrZSB0byBhdm9pZCBpcyBhbiBNUFggdm1hIGdldHRp
bmcgbWVyZ2VkIHdpdGggYQ0KPj4gbm9uLU1QWCB2bWEuICBJIGRvbid0IHNlZSBhbnkgY29kZSB0
byBwcmV2ZW50IHR3byBWTUFzIHdpdGgNCj4+IGRpZmZlcmVudCB2bV9vcHMtPm5hbWVzIGZyb20g
Z2V0dGluZyBtZXJnZWQuICBUaGF0IHNlZW1zIGxpa2UgYSBiaXQNCj4+IG9mIGEgZGVzaWduIG92
ZXJzaWdodCBmb3IgLT5uYW1lLiAgUmlnaHQ/DQo+IA0KPiBBRkFJSyB0aGVyZSBhcmUgbm8gLT5u
YW1lIHVzZXJzIHRoYXQgZG9uJ3QgYWxzbyBzZXQgLT5jbG9zZSwgZm9yDQo+IGV4YWN0bHkgdGhh
dCByZWFzb24uICBJJ2QgYmUgb2theSB3aXRoIGFkZGluZyBhIGNoZWNrIGZvciAtPm5hbWUsIHRv
by4NCj4gDQo+IEhtbS4gIElmIE1QWCB2bWFzIGhhZCBhIHJlYWwgc3RydWN0IGZpbGUgYXR0YWNo
ZWQsIHRoaXMgd291bGQgYWxsIGNvbWUNCj4gZm9yIGZyZWUuIE1heWJlIHZtYXMgd2l0aCBub24t
ZGVmYXVsdCB2bV9vcHMgYW5kIGZpbGUgIT0gTlVMTCBzaG91bGQNCj4gbmV2ZXIgYmUgbWVyZ2Vh
YmxlPw0KPiANCj4+IA0KPj4gVGhpbmtpbmcgb3V0IGxvdWQgYSBiaXQuLi4gVGhlcmUgYXJlIGFs
c28gc29tZSBtb3JlIGNvbXBsaWNhdGVkIGJ1dA0KPj4gbW9yZSBwZXJmb3JtYW50IGNsZWFudXAg
bWVjaGFuaXNtcyB0aGF0IEknZCBsaWtlIHRvIGdvIGFmdGVyIGluIHRoZSBmdXR1cmUuDQo+PiBH
aXZlbiBhIHBhZ2UsIHdlIG1pZ2h0IHdhbnQgdG8gZmlndXJlIG91dCBpZiBpdCBpcyBhbiBNUFgg
cGFnZSBvciBub3QuDQo+PiBJIHdvbmRlciBpZiB3ZSdsbCBldmVyIGNvbGxpZGUgd2l0aCBzb21l
IG90aGVyIHVzZXIgb2Ygdm1fb3BzLT5uYW1lLg0KPj4gSXQgbG9va3MgZmFpcmx5IG5hcnJvd2x5
IHVzZWQgYXQgdGhlIG1vbWVudCwgYnV0IHdvdWxkIHRoaXMga2VlcCB1cw0KPj4gZnJvbSBwdXR0
aW5nIHRoZXNlIHBhZ2VzIG9uLCBzYXksIGEgdG1wZnMgbW91bnQ/ICBEb2Vzbid0IGxvb2sgdGhh
dA0KPj4gd2F5IGF0IHRoZSBtb21lbnQuDQo+IA0KPiBZb3UgY291bGQgYWx3YXlzIGNoZWNrIHRo
ZSB2bV9vcHMgcG9pbnRlciB0byBzZWUgaWYgaXQncyBNUFguDQo+IA0KPiBPbmUgZmVhdHVyZSBJ
J3ZlIHdhbnRlZDogYSB3YXkgdG8gaGF2ZSBzcGVjaWFsIHBlci1wcm9jZXNzIHZtYXMgdGhhdA0K
PiBjYW4gYmUgZWFzaWx5IGZvdW5kLiAgRm9yIGV4YW1wbGUsIEkgd2FudCB0byBiZSBhYmxlIHRv
IGVmZmljaWVudGx5DQo+IGZpbmQgb3V0IHdoZXJlIHRoZSB2ZHNvIGFuZCB2dmFyIHZtYXMgYXJl
LiAgSSBkb24ndCB0aGluayB0aGlzIGlzIGN1cnJlbnRseSBzdXBwb3J0ZWQuDQo+IA0KQW5keSwg
aWYgeW91IGFkZCBhIGNoZWNrIGZvciAtPm5hbWUgdG8gYXZvaWQgdGhlIE1QWCB2bWFzIG1lcmdl
ZCB3aXRoIG5vbi1NUFggdm1hcywgSSBndWVzcyB0aGUgd29yayBmbG93IHNob3VsZCBiZSBhcyBm
b2xsb3cgKHVzZSBfaW5zdGFsbF9zcGVjaWFsX21hcHBpbmcgdG8gZ2V0IGEgbmV3IHZtYSk6DQoN
CnVuc2lnbmVkIGxvbmcgbXB4X21tYXAodW5zaWduZWQgbG9uZyBsZW4pDQp7DQogICAgLi4uLi4u
DQogICAgc3RhdGljIHN0cnVjdCB2bV9zcGVjaWFsX21hcHBpbmcgbXB4X21hcHBpbmcgPSB7DQog
ICAgICAgIC5uYW1lID0gIlttcHhdIiwNCiAgICAgICAgLnBhZ2VzID0gbm9fcGFnZXMsDQogICAg
fTsNCg0KICAgIC4uLi4uLi4NCiAgICB2bWEgPSBfaW5zdGFsbF9zcGVjaWFsX21hcHBpbmcobW0s
IGFkZHIsIGxlbiwgdm1fZmxhZ3MsICZtcHhfbWFwcGluZyk7DQogICAgLi4uLi4uDQp9DQoNClRo
ZW4sIHdlIGNvdWxkIGNoZWNrIHRoZSAtPm5hbWUgdG8gc2VlIGlmIHRoZSBWTUEgaXMgTVBYIHNw
ZWNpZmljLiBSaWdodD8NCg0KVGhhbmtzLA0KUWlhb3dlaQ0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 61B806B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:41:21 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id un15so994932pbc.27
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:41:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nd4si2894997pbc.20.2014.06.24.18.41.19
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 18:41:20 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Date: Wed, 25 Jun 2014 01:40:48 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com>
 <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com>
 <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com>
 <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com>
 <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com>
In-Reply-To: <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

T24gMjAxNC0wNi0yNSwgQW5keSBMdXRvbWlyc2tpIHdyb3RlOg0KPiBPbiBNb24sIEp1biAyMywg
MjAxNCBhdCAxMDo1MyBQTSwgUmVuLCBRaWFvd2VpIDxxaWFvd2VpLnJlbkBpbnRlbC5jb20+DQo+
IHdyb3RlOg0KPj4gT24gMjAxNC0wNi0yNCwgQW5keSBMdXRvbWlyc2tpIHdyb3RlOg0KPj4+PiBP
biAwNi8yMy8yMDE0IDAxOjA2IFBNLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6DQo+Pj4+PiBDYW4g
dGhlIG5ldyB2bV9vcGVyYXRpb24gIm5hbWUiIGJlIHVzZSBmb3IgdGhpcz8gIFRoZSBtYWdpYw0K
Pj4+Pj4gImFsd2F5cyB3cml0dGVuIHRvIGNvcmUgZHVtcHMiIGZlYXR1cmUgbWlnaHQgbmVlZCB0
byBiZSByZWNvbnNpZGVyZWQuDQo+Pj4+IA0KPj4+PiBPbmUgdGhpbmcgSSdkIGxpa2UgdG8gYXZv
aWQgaXMgYW4gTVBYIHZtYSBnZXR0aW5nIG1lcmdlZCB3aXRoIGENCj4+Pj4gbm9uLU1QWCB2bWEu
ICBJIGRvbid0IHNlZSBhbnkgY29kZSB0byBwcmV2ZW50IHR3byBWTUFzIHdpdGgNCj4+Pj4gZGlm
ZmVyZW50IHZtX29wcy0+bmFtZXMgZnJvbSBnZXR0aW5nIG1lcmdlZC4gIFRoYXQgc2VlbXMgbGlr
ZSBhDQo+Pj4+IGJpdCBvZiBhIGRlc2lnbiBvdmVyc2lnaHQgZm9yIC0+bmFtZS4gIFJpZ2h0Pw0K
Pj4+IA0KPj4+IEFGQUlLIHRoZXJlIGFyZSBubyAtPm5hbWUgdXNlcnMgdGhhdCBkb24ndCBhbHNv
IHNldCAtPmNsb3NlLCBmb3INCj4+PiBleGFjdGx5IHRoYXQgcmVhc29uLiAgSSdkIGJlIG9rYXkg
d2l0aCBhZGRpbmcgYSBjaGVjayBmb3IgLT5uYW1lLCB0b28uDQo+Pj4gDQo+Pj4gSG1tLiAgSWYg
TVBYIHZtYXMgaGFkIGEgcmVhbCBzdHJ1Y3QgZmlsZSBhdHRhY2hlZCwgdGhpcyB3b3VsZCBhbGwN
Cj4+PiBjb21lIGZvciBmcmVlLiBNYXliZSB2bWFzIHdpdGggbm9uLWRlZmF1bHQgdm1fb3BzIGFu
ZCBmaWxlICE9IE5VTEwNCj4+PiBzaG91bGQgbmV2ZXIgYmUgbWVyZ2VhYmxlPw0KPj4+IA0KPj4+
PiANCj4+Pj4gVGhpbmtpbmcgb3V0IGxvdWQgYSBiaXQuLi4gVGhlcmUgYXJlIGFsc28gc29tZSBt
b3JlIGNvbXBsaWNhdGVkDQo+Pj4+IGJ1dCBtb3JlIHBlcmZvcm1hbnQgY2xlYW51cCBtZWNoYW5p
c21zIHRoYXQgSSdkIGxpa2UgdG8gZ28gYWZ0ZXIgaW4gdGhlIGZ1dHVyZS4NCj4+Pj4gR2l2ZW4g
YSBwYWdlLCB3ZSBtaWdodCB3YW50IHRvIGZpZ3VyZSBvdXQgaWYgaXQgaXMgYW4gTVBYIHBhZ2Ug
b3Igbm90Lg0KPj4+PiBJIHdvbmRlciBpZiB3ZSdsbCBldmVyIGNvbGxpZGUgd2l0aCBzb21lIG90
aGVyIHVzZXIgb2Ygdm1fb3BzLT5uYW1lLg0KPj4+PiBJdCBsb29rcyBmYWlybHkgbmFycm93bHkg
dXNlZCBhdCB0aGUgbW9tZW50LCBidXQgd291bGQgdGhpcyBrZWVwDQo+Pj4+IHVzIGZyb20gcHV0
dGluZyB0aGVzZSBwYWdlcyBvbiwgc2F5LCBhIHRtcGZzIG1vdW50PyAgRG9lc24ndCBsb29rDQo+
Pj4+IHRoYXQgd2F5IGF0IHRoZSBtb21lbnQuDQo+Pj4gDQo+Pj4gWW91IGNvdWxkIGFsd2F5cyBj
aGVjayB0aGUgdm1fb3BzIHBvaW50ZXIgdG8gc2VlIGlmIGl0J3MgTVBYLg0KPj4+IA0KPj4+IE9u
ZSBmZWF0dXJlIEkndmUgd2FudGVkOiBhIHdheSB0byBoYXZlIHNwZWNpYWwgcGVyLXByb2Nlc3Mg
dm1hcyB0aGF0DQo+Pj4gY2FuIGJlIGVhc2lseSBmb3VuZC4gIEZvciBleGFtcGxlLCBJIHdhbnQg
dG8gYmUgYWJsZSB0byBlZmZpY2llbnRseQ0KPj4+IGZpbmQgb3V0IHdoZXJlIHRoZSB2ZHNvIGFu
ZCB2dmFyIHZtYXMgYXJlLiAgSSBkb24ndCB0aGluayB0aGlzIGlzDQo+Pj4gY3VycmVudGx5IHN1
cHBvcnRlZC4NCj4+PiANCj4+IEFuZHksIGlmIHlvdSBhZGQgYSBjaGVjayBmb3IgLT5uYW1lIHRv
IGF2b2lkIHRoZSBNUFggdm1hcyBtZXJnZWQNCj4+IHdpdGgNCj4gbm9uLU1QWCB2bWFzLCBJIGd1
ZXNzIHRoZSB3b3JrIGZsb3cgc2hvdWxkIGJlIGFzIGZvbGxvdyAodXNlDQo+IF9pbnN0YWxsX3Nw
ZWNpYWxfbWFwcGluZyB0byBnZXQgYSBuZXcgdm1hKToNCj4+IA0KPj4gdW5zaWduZWQgbG9uZyBt
cHhfbW1hcCh1bnNpZ25lZCBsb25nIGxlbikgew0KPj4gICAgIC4uLi4uLg0KPj4gICAgIHN0YXRp
YyBzdHJ1Y3Qgdm1fc3BlY2lhbF9tYXBwaW5nIG1weF9tYXBwaW5nID0gew0KPj4gICAgICAgICAu
bmFtZSA9ICJbbXB4XSIsDQo+PiAgICAgICAgIC5wYWdlcyA9IG5vX3BhZ2VzLA0KPj4gICAgIH07
DQo+PiAgICAgDQo+PiAgICAgLi4uLi4uLiB2bWEgPSBfaW5zdGFsbF9zcGVjaWFsX21hcHBpbmco
bW0sIGFkZHIsIGxlbiwgdm1fZmxhZ3MsDQo+PiAgICAgJm1weF9tYXBwaW5nKTsgLi4uLi4uDQo+
PiB9DQo+PiANCj4+IFRoZW4sIHdlIGNvdWxkIGNoZWNrIHRoZSAtPm5hbWUgdG8gc2VlIGlmIHRo
ZSBWTUEgaXMgTVBYIHNwZWNpZmljLiBSaWdodD8NCj4gDQo+IERvZXMgdGhpcyBhY3R1YWxseSBj
cmVhdGUgYSB2bWEgYmFja2VkIHdpdGggcmVhbCBtZW1vcnk/ICBEb2Vzbid0IHRoaXMNCj4gbmVl
ZCB0byBnbyB0aHJvdWdoIGFub25fdm1hIG9yIHNvbWV0aGluZz8gIF9pbnN0YWxsX3NwZWNpYWxf
bWFwcGluZw0KPiBjb21wbGV0ZWx5IHByZXZlbnRzIG1lcmdpbmcuDQo+IA0KSG1tLCBfaW5zdGFs
bF9zcGVjaWFsX21hcHBpbmcgc2hvdWxkIGNvbXBsZXRlbHkgcHJldmVudCBtZXJnaW5nLCBldmVu
IGFtb25nIE1QWCB2bWFzLg0KDQpTbywgY291bGQgeW91IHRlbGwgbWUgaG93IHRvIHNldCBNUFgg
c3BlY2lmaWMgLT5uYW1lIHRvIHRoZSB2bWEgd2hlbiBpdCBpcyBjcmVhdGVkPyBTZWVtcyBsaWtl
IHRoYXQgSSBjb3VsZCBub3QgZmluZCBzdWNoIGludGVyZmFjZS4NCg0KVGhhbmtzLA0KUWlhb3dl
aQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

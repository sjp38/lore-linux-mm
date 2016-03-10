Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC2A6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 02:23:25 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id n5so23838005pfn.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 23:23:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 79si4099621pfm.61.2016.03.09.23.23.24
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 23:23:24 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC kernel 0/2]A PV solution for KVM live
 migration optimization
Date: Thu, 10 Mar 2016 07:22:38 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414A701@shsmsx102.ccr.corp.intel.com>
References: <1457593292-30686-1-git-send-email-jitendra.kolhe@hpe.com>
In-Reply-To: <1457593292-30686-1-git-send-email-jitendra.kolhe@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jitendra Kolhe <jitendra.kolhe@hpe.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>
Cc: "dgilbert@redhat.com" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

PiBPbiAzLzgvMjAxNiA0OjQ0IFBNLCBBbWl0IFNoYWggd3JvdGU6DQo+ID4gT24gKEZyaSkgMDQg
TWFyIDIwMTYgWzE1OjAyOjQ3XSwgSml0ZW5kcmEgS29saGUgd3JvdGU6DQo+ID4+Pj4NCj4gPj4+
PiAqIExpYW5nIExpIChsaWFuZy56LmxpQGludGVsLmNvbSkgd3JvdGU6DQo+ID4+Pj4+IFRoZSBj
dXJyZW50IFFFTVUgbGl2ZSBtaWdyYXRpb24gaW1wbGVtZW50YXRpb24gbWFyayB0aGUgYWxsIHRo
ZQ0KPiA+Pj4+PiBndWVzdCdzIFJBTSBwYWdlcyBhcyBkaXJ0aWVkIGluIHRoZSByYW0gYnVsayBz
dGFnZSwgYWxsIHRoZXNlDQo+ID4+Pj4+IHBhZ2VzIHdpbGwgYmUgcHJvY2Vzc2VkIGFuZCB0aGF0
IHRha2VzIHF1aXQgYSBsb3Qgb2YgQ1BVIGN5Y2xlcy4NCj4gPj4+Pj4NCj4gPj4+Pj4gRnJvbSBn
dWVzdCdzIHBvaW50IG9mIHZpZXcsIGl0IGRvZXNuJ3QgY2FyZSBhYm91dCB0aGUgY29udGVudCBp
bg0KPiA+Pj4+PiBmcmVlIHBhZ2VzLiBXZSBjYW4gbWFrZSB1c2Ugb2YgdGhpcyBmYWN0IGFuZCBz
a2lwIHByb2Nlc3NpbmcgdGhlDQo+ID4+Pj4+IGZyZWUgcGFnZXMgaW4gdGhlIHJhbSBidWxrIHN0
YWdlLCBpdCBjYW4gc2F2ZSBhIGxvdCBDUFUgY3ljbGVzIGFuZA0KPiA+Pj4+PiByZWR1Y2UgdGhl
IG5ldHdvcmsgdHJhZmZpYyBzaWduaWZpY2FudGx5IHdoaWxlIHNwZWVkIHVwIHRoZSBsaXZlDQo+
ID4+Pj4+IG1pZ3JhdGlvbiBwcm9jZXNzIG9idmlvdXNseS4NCj4gPj4+Pj4NCj4gPj4+Pj4gVGhp
cyBwYXRjaCBzZXQgaXMgdGhlIFFFTVUgc2lkZSBpbXBsZW1lbnRhdGlvbi4NCj4gPj4+Pj4NCj4g
Pj4+Pj4gVGhlIHZpcnRpby1iYWxsb29uIGlzIGV4dGVuZGVkIHNvIHRoYXQgUUVNVSBjYW4gZ2V0
IHRoZSBmcmVlIHBhZ2VzDQo+ID4+Pj4+IGluZm9ybWF0aW9uIGZyb20gdGhlIGd1ZXN0IHRocm91
Z2ggdmlydGlvLg0KPiA+Pj4+Pg0KPiA+Pj4+PiBBZnRlciBnZXR0aW5nIHRoZSBmcmVlIHBhZ2Vz
IGluZm9ybWF0aW9uIChhIGJpdG1hcCksIFFFTVUgY2FuIHVzZQ0KPiA+Pj4+PiBpdCB0byBmaWx0
ZXIgb3V0IHRoZSBndWVzdCdzIGZyZWUgcGFnZXMgaW4gdGhlIHJhbSBidWxrIHN0YWdlLg0KPiA+
Pj4+PiBUaGlzIG1ha2UgdGhlIGxpdmUgbWlncmF0aW9uIHByb2Nlc3MgbXVjaCBtb3JlIGVmZmlj
aWVudC4NCj4gPj4+Pg0KPiA+Pj4+IEhpLA0KPiA+Pj4+ICAgQW4gaW50ZXJlc3Rpbmcgc29sdXRp
b247IEkga25vdyBhIGZldyBkaWZmZXJlbnQgcGVvcGxlIGhhdmUgYmVlbg0KPiA+Pj4+IGxvb2tp
bmcgYXQgaG93IHRvIHNwZWVkIHVwIGJhbGxvb25lZCBWTSBtaWdyYXRpb24uDQo+ID4+Pj4NCj4g
Pj4+DQo+ID4+PiBPb2gsIGRpZmZlcmVudCBzb2x1dGlvbnMgZm9yIHRoZSBzYW1lIHB1cnBvc2Us
IGFuZCBib3RoIGJhc2VkIG9uIHRoZQ0KPiBiYWxsb29uLg0KPiA+Pg0KPiA+PiBXZSB3ZXJlIGFs
c28gdHlpbmcgdG8gYWRkcmVzcyBzaW1pbGFyIHByb2JsZW0sIHdpdGhvdXQgYWN0dWFsbHkNCj4g
Pj4gbmVlZGluZyB0byBtb2RpZnkgdGhlIGd1ZXN0IGRyaXZlci4gUGxlYXNlIGZpbmQgcGF0Y2gg
ZGV0YWlscyB1bmRlciBtYWlsDQo+IHdpdGggc3ViamVjdC4NCj4gPj4gbWlncmF0aW9uOiBza2lw
IHNlbmRpbmcgcmFtIHBhZ2VzIHJlbGVhc2VkIGJ5IHZpcnRpby1iYWxsb29uIGRyaXZlcg0KPiA+
DQo+ID4gVGhlIHNjb3BlIG9mIHRoaXMgcGF0Y2ggc2VyaWVzIHNlZW1zIHRvIGJlIHdpZGVyOiBk
b24ndCBzZW5kIGZyZWUNCj4gPiBwYWdlcyB0byBhIGRlc3QgYXQgYWxsLCB2cy4gZG9uJ3Qgc2Vu
ZCBwYWdlcyB0aGF0IGFyZSBiYWxsb29uZWQgb3V0Lg0KPiA+DQo+ID4gCQlBbWl0DQo+IA0KPiBI
aSwNCj4gDQo+IFRoYW5rcyBmb3IgeW91ciByZXNwb25zZS4gVGhlIHNjb3BlIG9mIHRoaXMgcGF0
Y2ggc2VyaWVzIGRvZXNu4oCZdCBzZWVtIHRvDQo+IHRha2UgY2FyZSBvZiBiYWxsb29uZWQgb3V0
IHBhZ2VzLiBUbyBiYWxsb29uIG91dCBhIGd1ZXN0IHJhbSBwYWdlIHRoZSBndWVzdA0KPiBiYWxs
b29uIGRyaXZlciBkb2VzIGEgYWxsb2NfcGFnZSgpIGFuZCB0aGVuIHJldHVybiB0aGUgZ3Vlc3Qg
cGZuIHRvIFFlbXUsIHNvDQo+IGJhbGxvb25lZCBvdXQgcGFnZXMgd2lsbCBub3QgYmUgc2VlbiBh
cyBmcmVlIHJhbSBwYWdlcyBieSB0aGUgZ3Vlc3QuDQo+IFRodXMgd2Ugd2lsbCBzdGlsbCBlbmQg
dXAgc2Nhbm5pbmcgKGZvciB6ZXJvIHBhZ2UpIGZvciBiYWxsb29uZWQgb3V0IHBhZ2VzDQo+IGR1
cmluZyBtaWdyYXRpb24uIEl0IHdvdWxkIGJlIGlkZWFsIGlmIHdlIGNvdWxkIGhhdmUgYm90aCBz
b2x1dGlvbnMuDQo+IA0KDQpBZ3JlZSwgIGZvciB1c2VycyB3aG8gY2FyZSBhYm91dCB0aGUgcGVy
Zm9ybWFuY2UsIGp1c3Qgc2tpcHBpbmcgdGhlIGZyZWUgcGFnZXMuDQpGb3IgdXNlcnMgd2hvIGhh
dmUgYWxyZWFkeSB0dXJuZWQgb24gdmlydGlvLWJhbGxvb24sICB5b3VyIHNvbHV0aW9uIGNhbiB0
YWtlIGVmZmVjdC4NCg0KTGlhbmcNCj4gVGhhbmtzLA0KPiAtIEppdGVuZHJhDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

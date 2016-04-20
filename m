Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF6776B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 20:57:31 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so43758254pab.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 17:57:31 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ul1si14946850pab.19.2016.04.19.17.57.30
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 17:57:31 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Wed, 20 Apr 2016 00:57:27 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041832A5@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
	 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
	 <1461077659.3200.8.camel@redhat.com>
	 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <1461079592.3200.9.camel@redhat.com>
In-Reply-To: <1461079592.3200.9.camel@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

PiBPbiBUdWUsIDIwMTYtMDQtMTkgYXQgMTU6MDIgKzAwMDAsIExpLCBMaWFuZyBaIHdyb3RlOg0K
PiA+ID4NCj4gPiA+IE9uIFR1ZSwgMjAxNi0wNC0xOSBhdCAyMjozNCArMDgwMCwgTGlhbmcgTGkg
d3JvdGU6DQo+ID4gPiA+DQo+ID4gPiA+IFRoZSBmcmVlIHBhZ2UgYml0bWFwIHdpbGwgYmUgc2Vu
dCB0byBRRU1VIHRocm91Z2ggdmlydGlvIGludGVyZmFjZQ0KPiA+ID4gPiBhbmQgdXNlZCBmb3Ig
bGl2ZSBtaWdyYXRpb24gb3B0aW1pemF0aW9uLg0KPiA+ID4gPiBEcm9wIHRoZSBjYWNoZSBiZWZv
cmUgYnVpbGRpbmcgdGhlIGZyZWUgcGFnZSBiaXRtYXAgY2FuIGdldCBtb3JlDQo+ID4gPiA+IGZy
ZWUgcGFnZXMuIFdoZXRoZXIgZHJvcHBpbmcgdGhlIGNhY2hlIGlzIGRlY2lkZWQgYnkgdXNlci4N
Cj4gPiA+ID4NCj4gPiA+IEhvdyBkbyB5b3UgcHJldmVudCB0aGUgZ3Vlc3QgZnJvbSB1c2luZyB0
aG9zZSByZWNlbnRseS1mcmVlZCBwYWdlcw0KPiA+ID4gZm9yIHNvbWV0aGluZyBlbHNlLCBiZXR3
ZWVuIHdoZW4geW91IGJ1aWxkIHRoZSBiaXRtYXAgYW5kIHRoZSBsaXZlDQo+ID4gPiBtaWdyYXRp
b24gY29tcGxldGVzPw0KPiA+IEJlY2F1c2UgdGhlIGRpcnR5IHBhZ2UgbG9nZ2luZyBpcyBlbmFi
bGVkIGJlZm9yZSBidWlsZGluZyB0aGUgYml0bWFwLA0KPiA+IHRoZXJlIGlzIG5vIG5lZWQgdG8g
cHJldmVudCB0aGUgZ3Vlc3QgZnJvbSB1c2luZyB0aGUgcmVjZW50bHktZnJlZWQNCj4gPiBwYWdl
cyAuLi4NCj4gDQo+IEZhaXIgZW5vdWdoLg0KPiANCj4gSXQgd291bGQgYmUgZ29vZCB0byBoYXZl
IHRoYXQgbWVudGlvbmVkIGluIHRoZSBjaGFuZ2Vsb2cuDQoNClllcywgSSB3aWxsLiBUaGFua3Mh
DQoNCkxpYW5nDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

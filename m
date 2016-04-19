Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 984136B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 11:02:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so33529285pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:02:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id s1si10730126paw.158.2016.04.19.08.02.14
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 08:02:14 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Tue, 19 Apr 2016 15:02:09 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
	 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
In-Reply-To: <1461077659.3200.8.camel@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

PiBPbiBUdWUsIDIwMTYtMDQtMTkgYXQgMjI6MzQgKzA4MDAsIExpYW5nIExpIHdyb3RlOg0KPiA+
IFRoZSBmcmVlIHBhZ2UgYml0bWFwIHdpbGwgYmUgc2VudCB0byBRRU1VIHRocm91Z2ggdmlydGlv
IGludGVyZmFjZSBhbmQNCj4gPiB1c2VkIGZvciBsaXZlIG1pZ3JhdGlvbiBvcHRpbWl6YXRpb24u
DQo+ID4gRHJvcCB0aGUgY2FjaGUgYmVmb3JlIGJ1aWxkaW5nIHRoZSBmcmVlIHBhZ2UgYml0bWFw
IGNhbiBnZXQgbW9yZSBmcmVlDQo+ID4gcGFnZXMuIFdoZXRoZXIgZHJvcHBpbmcgdGhlIGNhY2hl
IGlzIGRlY2lkZWQgYnkgdXNlci4NCj4gPg0KPiANCj4gSG93IGRvIHlvdSBwcmV2ZW50IHRoZSBn
dWVzdCBmcm9tIHVzaW5nIHRob3NlIHJlY2VudGx5LWZyZWVkIHBhZ2VzIGZvcg0KPiBzb21ldGhp
bmcgZWxzZSwgYmV0d2VlbiB3aGVuIHlvdSBidWlsZCB0aGUgYml0bWFwIGFuZCB0aGUgbGl2ZSBt
aWdyYXRpb24NCj4gY29tcGxldGVzPw0KDQpCZWNhdXNlIHRoZSBkaXJ0eSBwYWdlIGxvZ2dpbmcg
aXMgZW5hYmxlZCBiZWZvcmUgYnVpbGRpbmcgdGhlIGJpdG1hcCwgdGhlcmUgaXMgbm8gbmVlZA0K
dG8gcHJldmVudCB0aGUgZ3Vlc3QgZnJvbSB1c2luZyB0aGUgcmVjZW50bHktZnJlZWQgcGFnZXMg
Li4uDQoNCkxpYW5nDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

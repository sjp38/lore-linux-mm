Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 934776B74B1
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:08:49 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so11183830pgj.21
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:08:49 -0800 (PST)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [146.101.78.151])
        by mx.google.com with ESMTPS id v25si21448237pfg.135.2018.12.05.06.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 06:08:48 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/2] put_user_page*(): start converting the call sites
Date: Wed, 5 Dec 2018 14:08:54 +0000
Message-ID: <e7cac96b06664c46bde3abe72ecab2ee@AcuMS.aculab.com>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <b31c7b3359344e778fc525013eeece64@AcuMS.aculab.com>
 <cfba998a-8217-bf03-f0d0-c95708aea03d@nvidia.com>
In-Reply-To: <cfba998a-8217-bf03-f0d0-c95708aea03d@nvidia.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'John Hubbard' <jhubbard@nvidia.com>, "'john.hubbard@gmail.com'" <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Jan Kara <jack@suse.cz>, Tom Talpey <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, "Christoph Hellwig  <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams" <dan.j.williams@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, "Jason Gunthorpe  <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox" <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

RnJvbTogSm9obiBIdWJiYXJkDQo+IFNlbnQ6IDA1IERlY2VtYmVyIDIwMTggMDE6MDYNCj4gT24g
MTIvNC8xOCA5OjEwIEFNLCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4gRnJvbTogam9obi5odWJi
YXJkQGdtYWlsLmNvbQ0KPiA+PiBTZW50OiAwNCBEZWNlbWJlciAyMDE4IDAwOjE3DQo+ID4+DQo+
ID4+IFN1bW1hcnk6IEknZCBsaWtlIHRoZXNlIHR3byBwYXRjaGVzIHRvIGdvIGludG8gdGhlIG5l
eHQgY29udmVuaWVudCBjeWNsZS4NCj4gPj4gSSAqdGhpbmsqIHRoYXQgbWVhbnMgNC4yMS4NCj4g
Pj4NCj4gPj4gRGV0YWlscw0KPiA+Pg0KPiA+PiBBdCB0aGUgTGludXggUGx1bWJlcnMgQ29uZmVy
ZW5jZSwgd2UgdGFsa2VkIGFib3V0IHRoaXMgYXBwcm9hY2ggWzFdLCBhbmQNCj4gPj4gdGhlIHBy
aW1hcnkgbGluZ2VyaW5nIGNvbmNlcm4gd2FzIG92ZXIgcGVyZm9ybWFuY2UuIFRvbSBUYWxwZXkg
aGVscGVkIG1lDQo+ID4+IHRocm91Z2ggYSBtdWNoIG1vcmUgYWNjdXJhdGUgcnVuIG9mIHRoZSBm
aW8gcGVyZm9ybWFuY2UgdGVzdCwgYW5kIG5vdw0KPiA+PiBpdCdzIGxvb2tpbmcgbGlrZSBhbiB1
bmRlciAxJSBwZXJmb3JtYW5jZSBjb3N0LCB0byBhZGQgYW5kIHJlbW92ZSBwYWdlcw0KPiA+PiBm
cm9tIHRoZSBMUlUgKHRoaXMgaXMgb25seSBwYWlkIHdoZW4gZGVhbGluZyB3aXRoIGdldF91c2Vy
X3BhZ2VzKSBbMl0uIFNvDQo+ID4+IHdlIHNob3VsZCBiZSBmaW5lIHRvIHN0YXJ0IGNvbnZlcnRp
bmcgY2FsbCBzaXRlcy4NCj4gPj4NCj4gPj4gVGhpcyBwYXRjaHNldCBnZXRzIHRoZSBjb252ZXJz
aW9uIHN0YXJ0ZWQuIEJvdGggcGF0Y2hlcyBhbHJlYWR5IGhhZCBhIGZhaXINCj4gPj4gYW1vdW50
IG9mIHJldmlldy4NCj4gPg0KPiA+IFNob3VsZG4ndCB0aGUgY29tbWl0IG1lc3NhZ2UgY29udGFp
biBhY3R1YWwgZGV0YWlscyBvZiB0aGUgY2hhbmdlPw0KPiA+DQo+IA0KPiBIaSBEYXZpZCwNCj4g
DQo+IFRoaXMgInBhdGNoIDAwMDAiIGlzIG5vdCBhIGNvbW1pdCBtZXNzYWdlLCBhcyBpdCBuZXZl
ciBzaG93cyB1cCBpbiBnaXQgbG9nLg0KPiBFYWNoIG9mIHRoZSBmb2xsb3ctdXAgcGF0Y2hlcyBk
b2VzIGhhdmUgZGV0YWlscyBhYm91dCB0aGUgY2hhbmdlcyBpdCBtYWtlcy4NCg0KSSB0aGluayB5
b3Ugc2hvdWxkIHN0aWxsIGRlc2NyaWJlIHRoZSBjaGFuZ2UgLSBhdCBsZWFzdCBpbiBzdW1tYXJ5
Lg0KDQpUaGUgcGF0Y2ggSSBsb29rZWQgYXQgZGlkbid0IHJlYWxseS4uLg0KSUlSQyBpdCBzdGls
bCByZWZlcnJlZCB0byBleHRlcm5hbCBsaW5rcy4NCg0KPiBCdXQgbWF5YmUgeW91IGFyZSByZWFs
bHkgYXNraW5nIGZvciBtb3JlIGJhY2tncm91bmQgaW5mb3JtYXRpb24sIHdoaWNoIEkNCj4gc2hv
dWxkIGhhdmUgYWRkZWQgaW4gdGhpcyBjb3ZlciBsZXR0ZXIuIEhlcmUncyBhIHN0YXJ0Og0KPiAN
Cj4gaHR0cHM6Ly9sb3JlLmtlcm5lbC5vcmcvci8yMDE4MTExMDA4NTA0MS4xMDA3MS0xLWpodWJi
YXJkQG52aWRpYS5jb20NCg0KWWVzLCBidXQgbGlua3MgZ28gc3RhbGUuLi4uDQoNCj4gLi4uYW5k
IGl0IGxvb2tzIGxpa2UgdGhpcyBzbWFsbCBwYXRjaCBzZXJpZXMgaXMgbm90IGdvaW5nIHRvIHdv
cmsgb3V0LS1JJ20NCj4gZ29pbmcgdG8gaGF2ZSB0byBmYWxsIGJhY2sgdG8gYW5vdGhlciBSRkMg
c3Bpbi4gU28gSSdsbCBiZSBzdXJlIHRvIGluY2x1ZGUNCj4geW91IGFuZCBldmVyeW9uZSBvbiB0
aGF0LiBIb3BlIHRoYXQgaGVscHMuDQoNCglEYXZpZA0KDQotDQpSZWdpc3RlcmVkIEFkZHJlc3Mg
TGFrZXNpZGUsIEJyYW1sZXkgUm9hZCwgTW91bnQgRmFybSwgTWlsdG9uIEtleW5lcywgTUsxIDFQ
VCwgVUsNClJlZ2lzdHJhdGlvbiBObzogMTM5NzM4NiAoV2FsZXMpDQo=

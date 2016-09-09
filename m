Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30A716B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 13:21:42 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e1so71501631itb.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 10:21:42 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0099.outbound.protection.outlook.com. [104.47.41.99])
        by mx.google.com with ESMTPS id d190si2871604oih.234.2016.09.09.10.21.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 10:21:41 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Date: Fri, 9 Sep 2016 17:21:40 +0000
Message-ID: <1473441640.2092.74.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
	 <20160829204842.GA27286@node.shutemov.name>
	 <1472506310.1532.47.camel@hpe.com> <1472508000.1532.59.camel@hpe.com>
	 <20160908105707.GA17331@node> <1473342519.2092.42.camel@hpe.com>
	 <1473376846.2092.69.camel@hpe.com>
	 <20160909123608.GA75965@black.fi.intel.com>
In-Reply-To: <20160909123608.GA75965@black.fi.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E9E20E8BB889D54C8FC1067DA1704F20@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Cc: "hughd@google.com" <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTA5LTA5IGF0IDE1OjM2ICswMzAwLCBLaXJpbGwgQS4gU2h1dGVtb3Ygd3Jv
dGU6DQo+IE9uIFRodSwgU2VwIDA4LCAyMDE2IGF0IDExOjIxOjQ2UE0gKzAwMDAsIEthbmksIFRv
c2hpbWl0c3Ugd3JvdGU6DQo+ID4gDQo+ID4gT24gVGh1LCAyMDE2LTA5LTA4IGF0IDA3OjQ4IC0w
NjAwLCBLYW5pLCBUb3NoaW1pdHN1IHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBPbiBUaHUsIDIwMTYt
MDktMDggYXQgMTM6NTcgKzAzMDAsIEtpcmlsbCBBLiBTaHV0ZW1vdiB3cm90ZToNCj4gPiA+ID4g
DQo+ID4gPiA+IE9uIE1vbiwgQXVnIDI5LCAyMDE2IGF0IDEwOjAwOjQzUE0gKzAwMDAsIEthbmks
IFRvc2hpbWl0c3UNCj4gPiA+ID4gd3JvdGU6DQo+ID4gwqA6DQo+ID4gPiA+ID4gTG9va2luZyBm
dXJ0aGVyLCB0aGVzZSBzaG1lbV9odWdlIGhhbmRsaW5ncyBvbmx5IGNoZWNrIHByZS0NCj4gPiA+
ID4gPiBjb25kaXRpb25zLsKgwqBTbyzCoHdlwqBzaG91bGTCoGJlwqBhYmxlwqB0b8KgbWFrZcKg
c2htZW1fZ2V0X3VubWFwcGVkDQo+ID4gPiA+ID4gX2FyZSBhKCkgYXMgYSB3cmFwcGVyLCB3aGlj
aCBjaGVja3Mgc3VjaCBzaG1lbS1zcGVjaWZpYw0KPiA+ID4gPiA+IGNvbml0aW9ucywgYW5kIHRo
ZW7CoGNhbGzCoF9fdGhwX2dldF91bm1hcHBlZF9hcmVhKCkgZm9yIHRoZQ0KPiA+ID4gPiA+IGFj
dHVhbCB3b3JrLiDCoEFsbCBEQVgtc3BlY2lmaWMgY2hlY2tzIGFyZSBwZXJmb3JtZWQgaW4NCj4g
PiA+ID4gPiB0aHBfZ2V0X3VubWFwcGVkX2FyZWEoKSBhcyB3ZWxsLiDCoFdlIGNhbiBtYWtlDQo+
ID4gPiA+ID4gwqBfX3RocF9nZXRfdW5tYXBwZWRfYXJlYSgpIGFzIGEgY29tbW9uDQo+ID4gPiA+
ID4gZnVuY3Rpb24uDQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gSSdkIHByZWZlciB0byBtYWtlIHN1
Y2ggY2hhbmdlIGFzIGEgc2VwYXJhdGUgaXRlbSwNCj4gPiA+ID4gDQo+ID4gPiA+IERvIHlvdSBo
YXZlIHBsYW4gdG8gc3VibWl0IHN1Y2ggY2hhbmdlPw0KPiA+ID4gDQo+ID4gPiBZZXMsIEkgd2ls
bCBzdWJtaXQgdGhlIGNoYW5nZSBvbmNlIEkgZmluaXNoIHRlc3RpbmcuDQo+ID4gDQo+ID4gSSBm
b3VuZCBhIGJ1ZyBpbiB0aGUgY3VycmVudCBjb2RlLCBhbmQgbmVlZCBzb21lIGNsYXJpZmljYXRp
b24uDQo+ID4gwqBUaGUgaWYtc3RhdGVtZW50IGJlbG93IGlzIHJldmVydGVkLg0KPiANCj4gPHR3
by1oYW5kcy1mYWNlcGFsbT4NCj4gDQo+IFllYWguIEl0IHdhcyByZXBvcmVkIGJ5IEhpbGxmWzFd
LiBUaGUgZml4dXAgZ290IGxvc3QuIDooDQo+IA0KPiBDb3VsZCB5b3UgcG9zdCBhIHByb3BlciBw
YXRjaCB3aXRoIHRoZSBmaXg/DQo+DQo+IEkgd291bGQgYmUgbmljZSB0byBjcmVkaXQgSGlsbGYg
dGhlcmUgdG9vLg0KPiANCj4gWzFdIGh0dHA6Ly9sa21sLmtlcm5lbC5vcmcvci8wNTRmMDFkMWM4
NmYkMjk5NGQ1YzAkN2NiZTgxNDAkQGFsaWJhYmEtDQo+IGluYy5jb20NCg0KWWVzLCBJIHdpbGwg
c3VibWl0IHRoZSBmaXggYXMgd2VsbC4NCg0KSSB3aWxsIG5vdCBjaGFuZ2UgdGhlIGRlZmF1bHQg
dmFsdWUgb2Ygc2JpbmZvLT5odWdlIGluIHRoaXMgZml4LiDCoFNvLA0KdXNlciB3aWxsIGhhdmUg
dG8gc3BlY2lmeSAiaHVnZT0iIG9wdGlvbiB0byBlbmFibGUgaHVnZSBwYWdlIG1hcHBpbmdzLg0K
wqBJZiB0aGlzIGlzIG5vdCBkZXNpcmVhYmxlLCB3ZSB3aWxsIG5lZWQgYSBzZXBhcmF0ZSBwYXRj
aC4NCg0KVGhhbmtzLA0KLVRvc2hpDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

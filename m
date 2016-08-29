Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2066383102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 17:32:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u191so1312338oie.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 14:32:39 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0114.outbound.protection.outlook.com. [104.47.42.114])
        by mx.google.com with ESMTPS id c54si13414685otc.124.2016.08.29.14.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 14:32:35 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Date: Mon, 29 Aug 2016 21:32:32 +0000
Message-ID: <1472506310.1532.47.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
	 <20160829204842.GA27286@node.shutemov.name>
In-Reply-To: <20160829204842.GA27286@node.shutemov.name>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <444204165259F745936FF1BD624D64E6@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "hughd@google.com" <hughd@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gTW9uLCAyMDE2LTA4LTI5IGF0IDIzOjQ4ICswMzAwLCBLaXJpbGwgQS4gU2h1dGVtb3Ygd3Jv
dGU6DQo+IE9uIE1vbiwgQXVnIDI5LCAyMDE2IGF0IDAxOjExOjE5UE0gLTA2MDAsIFRvc2hpIEth
bmkgd3JvdGU6DQo+ID4gDQo+ID4gV2hlbiBDT05GSUdfRlNfREFYX1BNRCBpcyBzZXQsIERBWCBz
dXBwb3J0cyBtbWFwKCkgdXNpbmcgcG1kIHBhZ2UNCj4gPiBzaXplLsKgwqBUaGlzIGZlYXR1cmUg
cmVsaWVzIG9uIGJvdGggbW1hcCB2aXJ0dWFsIGFkZHJlc3MgYW5kIEZTDQo+ID4gYmxvY2sgKGku
ZS4gcGh5c2ljYWwgYWRkcmVzcykgdG8gYmUgYWxpZ25lZCBieSB0aGUgcG1kIHBhZ2Ugc2l6ZS4N
Cj4gPiBVc2VycyBjYW4gdXNlIG1rZnMgb3B0aW9ucyB0byBzcGVjaWZ5IEZTIHRvIGFsaWduIGJs
b2NrDQo+ID4gYWxsb2NhdGlvbnMuIEhvd2V2ZXIsIGFsaWduaW5nIG1tYXAgYWRkcmVzcyByZXF1
aXJlcyBjb2RlIGNoYW5nZXMNCj4gPiB0byBleGlzdGluZyBhcHBsaWNhdGlvbnMgZm9yIHByb3Zp
ZGluZyBhIHBtZC1hbGlnbmVkIGFkZHJlc3MgdG8NCj4gPiBtbWFwKCkuDQo+ID4gDQo+ID4gRm9y
IGluc3RhbmNlLCBmaW8gd2l0aCAiaW9lbmdpbmU9bW1hcCIgcGVyZm9ybXMgSS9PcyB3aXRoIG1t
YXAoKQ0KPiA+IFsxXS4gSXQgY2FsbHMgbW1hcCgpIHdpdGggYSBOVUxMIGFkZHJlc3MsIHdoaWNo
IG5lZWRzIHRvIGJlIGNoYW5nZWQNCj4gPiB0byBwcm92aWRlIGEgcG1kLWFsaWduZWQgYWRkcmVz
cyBmb3IgdGVzdGluZyB3aXRoIERBWCBwbWQgbWFwcGluZ3MuDQo+ID4gQ2hhbmdpbmcgYWxsIGFw
cGxpY2F0aW9ucyB0aGF0IGNhbGwgbW1hcCgpIHdpdGggTlVMTCBpcw0KPiA+IHVuZGVzaXJhYmxl
Lg0KPiA+IA0KPiA+IFRoaXMgcGF0Y2gtc2V0IGV4dGVuZHMgZmlsZXN5c3RlbXMgdG8gYWxpZ24g
YW4gbW1hcCBhZGRyZXNzIGZvcg0KPiA+IGEgREFYIGZpbGUgc28gdGhhdCB1bm1vZGlmaWVkIGFw
cGxpY2F0aW9ucyBjYW4gdXNlIERBWCBwbWQNCj4gPiBtYXBwaW5ncy4NCj4gDQo+ICtIdWdoDQo+
IA0KPiBDYW4gd2UgZ2V0IGl0IHVzZWQgZm9yIHNobWVtL3RtcGZzIHRvbz8NCj4gSSBkb24ndCB0
aGluayB3ZSBzaG91bGQgZHVwbGljYXRlIGVzc2VudGlhbGx5IHRoZSBzYW1lIGZ1bmN0aW9uYWxp
dHkNCj4gaW4gbXVsdGlwbGUgcGxhY2VzLg0KDQpIZXJlIGlzIG15IGJyaWVmIGFuYWx5c2lzIHdo
ZW4gSSBoYWQgbG9va2VkIGF0IHRoZSBIdWdoJ3MgcGF0Y2ggbGFzdA0KdGltZSAoYmVmb3JlwqBz
aG1lbV9nZXRfdW5tYXBwZWRfYXJlYSgpIHdhcyBhY2NlcHRlZCkuDQpodHRwczovL3BhdGNod29y
ay5rZXJuZWwub3JnL3BhdGNoLzg5MTY3NDEvDQoNCkJlc2lkZXMgc29tZSBkaWZmZXJlbmNlcyBp
biB0aGUgbG9naWMsIGV4LiBzaG1lbV9nZXRfdW5tYXBwZWRfYXJlYSgpDQphbHdheXMgY2FsbHPC
oGN1cnJlbnQtPm1tLT5nZXRfdW5tYXBwZWRfYXJlYSB0d2ljZSwgeWVzLCB0aGV5IGJhc2ljYWxs
eQ0KcHJvdmlkZSB0aGUgc2FtZSBmdW5jdGlvbmFsaXR5Lg0KDQpJIHRoaW5rIG9uZSBpc3N1ZSBp
cyB0aGF0IHNobWVtX2dldF91bm1hcHBlZF9hcmVhKCkgY2hlY2tzIHdpdGggaXRzDQpzdGF0aWMg
ZmxhZyAnc2htZW1faHVnZScsIGFuZCBhZGRpdGluYWxseSBkZWFscyB3aXRoIFNITUVNX0hVR0Vf
REVOWQ0KYW5kwqBTSE1FTV9IVUdFX0ZPUkNFIGNhc2VzLiDCoEl0IGFsc28gaGFuZGxlcyBub24t
ZmlsZSBjYXNlIGZvcg0KIVNITUVNX0hVR0VfRk9SQ0UuDQoNClRoYW5rcywNCi1Ub3NoaQ0KDQoN
Cg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

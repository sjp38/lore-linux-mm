Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 839E06B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 16:30:46 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so4110456pdb.41
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 13:30:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id rf10si7178585pab.76.2014.07.31.13.30.45
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 13:30:45 -0700 (PDT)
From: "Zwisler, Ross" <ross.zwisler@intel.com>
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
Date: Thu, 31 Jul 2014 20:30:02 +0000
Message-ID: <1406838602.14136.12.camel@rzwisler-mobl1.amr.corp.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
	 <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com>
	 <53D9174C.7040906@gmail.com> <20140730194503.GQ6754@linux.intel.com>
	 <53DA165E.8040601@gmail.com> <20140731141315.GT6754@linux.intel.com>
	 <53DA60A5.1030304@gmail.com> <20140731171953.GU6754@linux.intel.com>
	 <53DA8518.3090604@gmail.com>
In-Reply-To: <53DA8518.3090604@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D7339778D56F9B42BA028B59A656DB6A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "openosd@gmail.com" <openosd@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@linux.intel.com" <willy@linux.intel.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVGh1LCAyMDE0LTA3LTMxIGF0IDIxOjA0ICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDA3LzMxLzIwMTQgMDg6MTkgUE0sIE1hdHRoZXcgV2lsY294IHdyb3RlOg0KPiA+IE9uIFRo
dSwgSnVsIDMxLCAyMDE0IGF0IDA2OjI4OjM3UE0gKzAzMDAsIEJvYXogSGFycm9zaCB3cm90ZToN
Cj4gPj4gTWF0dGhldyB3aGF0IGlzIHlvdXIgb3BpbmlvbiBhYm91dCB0aGlzLCBkbyB3ZSBuZWVk
IHRvIHB1c2ggZm9yIHJlbW92YWwNCj4gPj4gb2YgdGhlIHBhcnRpdGlvbiBkZWFkIGNvZGUgd2hp
Y2ggbmV2ZXIgd29ya2VkIGZvciBicmQsIG9yIHdlIG5lZWQgdG8gcHVzaA0KPiA+PiBmb3IgZml4
aW5nIGFuZCBpbXBsZW1lbnRpbmcgbmV3IHBhcnRpdGlvbiBzdXBwb3J0IGZvciBicmQ/DQo+ID4g
DQo+ID4gRml4aW5nIHRoZSBjb2RlIGdldHMgbXkgdm90ZS4gIGJyZCBpcyB1c2VmdWwgZm9yIHRl
c3RpbmcgdGhpbmdzIC4uLiBhbmQNCj4gPiBzb21ldGltZXMgd2UgbmVlZCB0byB0ZXN0IHRoaW5n
cyB0aGF0IGludm9sdmUgcGFydGl0aW9ucy4NCj4gPiANCj4gDQo+IE9LIEknbSBvbiBpdCwgaXRz
IHdoYXQgSSdtIGRvaW5nIHRvZGF5Lg0KPiANCj4gcnJyIEkgbWFuZ2VkIHRvIGNvbXBsZXRlbHkg
dHJhc2ggbXkgdm0gYnkgZG9pbmcgJ21ha2UgaW5zdGFsbCcgb2YNCj4gdXRpbC1saW51eCBhbmQg
YWZ0ZXIgcmVib290IGl0IG5ldmVyIHJlY292ZXJlZCwgSSByZW1lbWJlciB0aGF0DQo+IG1vdW50
IGNvbXBsYWluZWQgYWJvdXQgYSBub3cgbWlzc2luZyBsaWJyYXJ5IGFuZCBJIGZvcmdvdCBhbmQg
cmVib290ZWQsDQo+IHRoYXQgd2FzIHRoZSBlbmQgb2YgdGhhdC4gQW55d2F5IEkgaW5zdGFsbGVk
IGEgbmV3IGZjMjAgc3lzdGVtIHdhbnRlZA0KPiB0aGF0IGZvciBhIGxvbmcgdGltZSBvdmVyIG15
IG9sZCBmYzE4DQoNCkFoLCBJJ20gYWxyZWFkeSB3b3JraW5nIG9uIHRoaXMgYXMgd2VsbC4gIDop
ICBJZiB5b3Ugd2FudCB5b3UgY2FuIHdhaXQgZm9yIG15DQpwYXRjaGVzIHRvIEJSRCAmIHRlc3Qg
LSB0aGV5IHNob3VsZCBiZSBvdXQgdGhpcyB3ZWVrLg0KDQpJJ20gcGxhbm5pbmcgb24gYWRkaW5n
IGdldF9nZW8oKSBhbmQgZG9pbmcgZHluYW1pYyBtaW5vcnMgYXMgaXMgZG9uZSBpbiBOVk1lLg0K
DQotIFJvc3MNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

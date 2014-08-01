Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC796B0036
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 14:45:24 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so6243481pac.17
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 11:45:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ko9si10726099pab.125.2014.08.01.11.45.22
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 11:45:23 -0700 (PDT)
From: "Zwisler, Ross" <ross.zwisler@intel.com>
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
Date: Fri, 1 Aug 2014 18:45:20 +0000
Message-ID: <1406918720.3198.3.camel@rzwisler-mobl1.amr.corp.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
	 <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com>
	 <53D9174C.7040906@gmail.com> <20140730194503.GQ6754@linux.intel.com>
	 <53DA165E.8040601@gmail.com> <20140731141315.GT6754@linux.intel.com>
	 <53DA60A5.1030304@gmail.com> <20140731171953.GU6754@linux.intel.com>
	 <53DA8518.3090604@gmail.com>
	 <1406838602.14136.12.camel@rzwisler-mobl1.amr.corp.intel.com>
In-Reply-To: <1406838602.14136.12.camel@rzwisler-mobl1.amr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5CDAB0DF6035D34B987649760C33DA03@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "openosd@gmail.com" <openosd@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@linux.intel.com" <willy@linux.intel.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVGh1LCAyMDE0LTA3LTMxIGF0IDE0OjMwIC0wNjAwLCBSb3NzIFp3aXNsZXIgd3JvdGU6DQo+
IE9uIFRodSwgMjAxNC0wNy0zMSBhdCAyMTowNCArMDMwMCwgQm9heiBIYXJyb3NoIHdyb3RlOg0K
PiA+IE9uIDA3LzMxLzIwMTQgMDg6MTkgUE0sIE1hdHRoZXcgV2lsY294IHdyb3RlOg0KPiA+ID4g
T24gVGh1LCBKdWwgMzEsIDIwMTQgYXQgMDY6Mjg6MzdQTSArMDMwMCwgQm9heiBIYXJyb3NoIHdy
b3RlOg0KPiA+ID4+IE1hdHRoZXcgd2hhdCBpcyB5b3VyIG9waW5pb24gYWJvdXQgdGhpcywgZG8g
d2UgbmVlZCB0byBwdXNoIGZvciByZW1vdmFsDQo+ID4gPj4gb2YgdGhlIHBhcnRpdGlvbiBkZWFk
IGNvZGUgd2hpY2ggbmV2ZXIgd29ya2VkIGZvciBicmQsIG9yIHdlIG5lZWQgdG8gcHVzaA0KPiA+
ID4+IGZvciBmaXhpbmcgYW5kIGltcGxlbWVudGluZyBuZXcgcGFydGl0aW9uIHN1cHBvcnQgZm9y
IGJyZD8NCj4gPiA+IA0KPiA+ID4gRml4aW5nIHRoZSBjb2RlIGdldHMgbXkgdm90ZS4gIGJyZCBp
cyB1c2VmdWwgZm9yIHRlc3RpbmcgdGhpbmdzIC4uLiBhbmQNCj4gPiA+IHNvbWV0aW1lcyB3ZSBu
ZWVkIHRvIHRlc3QgdGhpbmdzIHRoYXQgaW52b2x2ZSBwYXJ0aXRpb25zLg0KPiA+ID4gDQo+ID4g
DQo+ID4gT0sgSSdtIG9uIGl0LCBpdHMgd2hhdCBJJ20gZG9pbmcgdG9kYXkuDQo+ID4gDQo+ID4g
cnJyIEkgbWFuZ2VkIHRvIGNvbXBsZXRlbHkgdHJhc2ggbXkgdm0gYnkgZG9pbmcgJ21ha2UgaW5z
dGFsbCcgb2YNCj4gPiB1dGlsLWxpbnV4IGFuZCBhZnRlciByZWJvb3QgaXQgbmV2ZXIgcmVjb3Zl
cmVkLCBJIHJlbWVtYmVyIHRoYXQNCj4gPiBtb3VudCBjb21wbGFpbmVkIGFib3V0IGEgbm93IG1p
c3NpbmcgbGlicmFyeSBhbmQgSSBmb3Jnb3QgYW5kIHJlYm9vdGVkLA0KPiA+IHRoYXQgd2FzIHRo
ZSBlbmQgb2YgdGhhdC4gQW55d2F5IEkgaW5zdGFsbGVkIGEgbmV3IGZjMjAgc3lzdGVtIHdhbnRl
ZA0KPiA+IHRoYXQgZm9yIGEgbG9uZyB0aW1lIG92ZXIgbXkgb2xkIGZjMTgNCj4gDQo+IEFoLCBJ
J20gYWxyZWFkeSB3b3JraW5nIG9uIHRoaXMgYXMgd2VsbC4gIDopICBJZiB5b3Ugd2FudCB5b3Ug
Y2FuIHdhaXQgZm9yIG15DQo+IHBhdGNoZXMgdG8gQlJEICYgdGVzdCAtIHRoZXkgc2hvdWxkIGJl
IG91dCB0aGlzIHdlZWsuDQo+IA0KPiBJJ20gcGxhbm5pbmcgb24gYWRkaW5nIGdldF9nZW8oKSBh
bmQgZG9pbmcgZHluYW1pYyBtaW5vcnMgYXMgaXMgZG9uZSBpbiBOVk1lLg0KDQpVZ2gsIGl0IHR1
cm5zIG91dCB0aGF0IGlmIHlvdSByZW1vdmUgdGhlICIqcGFydCA9IDAiIGJpdCBmcm9tIGJyZF9w
cm9iZSgpLA0KYXR0ZW1wdHMgdG8gY3JlYXRlIG5ldyBCUkQgZGV2aWNlcyB1c2luZyBta25vZCBo
aXQgYSBkZWFkbG9jay4gIFJlbW92YWwgb2YNCnRoYXQgY29kZSwgaWU6DQoNCkBAIC01NTAsNyAr
NTQ5LDYgQEAgc3RhdGljIHN0cnVjdCBrb2JqZWN0ICpicmRfcHJvYmUoZGV2X3QgZGV2LCBpbnQg
KnBhcnQsIHZvaWQgKmRhdGEpDQogICAgICAgIGtvYmogPSBicmQgPyBnZXRfZGlzayhicmQtPmJy
ZF9kaXNrKSA6IE5VTEw7DQogICAgICAgIG11dGV4X3VubG9jaygmYnJkX2RldmljZXNfbXV0ZXgp
Ow0KDQotICAgICAgICpwYXJ0ID0gMDsNCiAgICAgICAgcmV0dXJuIGtvYmo7DQogfQ0KDQppcyBu
ZWNlc3NhcnkgaWYgd2Ugd2FudCB0byBkbyBhbnkgc29ydCBvZiBwYXJ0aXRpb25pbmcuDQoNClRo
aXMgaXNuJ3QgYSB1c2UgY2FzZSBmb3IgUFJELCBzbyBJJ2xsIG1vdmUgb3ZlciB0byB0aGF0IGFu
ZCB0cnkgdG8gYWRkDQpkeW5hbWljIG1pbm9ycyB0aGVyZSBpbnN0ZWFkLiAgSWYgd2UgcmVhbGx5
IGRvIHdhbnQgcGFydGl0aW9ucyB0byB3b3JrIGluIEJSRCwNCnRob3VnaCwgZXZlbnR1YWxseSB3
ZSdsbCBoYXZlIHRvIGRlYnVnIHRoZSBkZWFkbG9jay4NCg0KLSBSb3NzDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id DF5A96B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 01:28:30 -0400 (EDT)
From: "Zheng, Lv" <lv.zheng@intel.com>
Subject: RE: [PATCH v2 07/18] x86, acpi: Also initialize signature and
 length when parsing root table.
Date: Fri, 2 Aug 2013 05:28:25 +0000
Message-ID: <1AE640813FDE7649BE1B193DEA596E8802437B03@SHSMSX101.ccr.corp.intel.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375340800-19332-8-git-send-email-tangchen@cn.fujitsu.com>
 <1375402250.10300.57.camel@misato.fc.hp.com>
In-Reply-To: <1375402250.10300.57.camel@misato.fc.hp.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tj@kernel.org" <tj@kernel.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Moore, Robert" <robert.moore@intel.com>

PiBGcm9tOiBsaW51eC1hY3BpLW93bmVyQHZnZXIua2VybmVsLm9yZw0KPiBTZW50OiBGcmlkYXks
IEF1Z3VzdCAwMiwgMjAxMyA4OjExIEFNDQo+IA0KPiBPbiBUaHUsIDIwMTMtMDgtMDEgYXQgMTU6
MDYgKzA4MDAsIFRhbmcgQ2hlbiB3cm90ZToNCj4gPiBCZXNpZGVzIHRoZSBwaHlzIGFkZHIgb2Yg
dGhlIGFjcGkgdGFibGVzLCBpdCB3aWxsIGJlIHZlcnkgY29udmVuaWVudCBpZg0KPiA+IHdlIGFs
c28gaGF2ZSB0aGUgc2lnbmF0dXJlIG9mIGVhY2ggdGFibGUgaW4gYWNwaV9nYmxfcm9vdF90YWJs
ZV9saXN0IGF0DQo+ID4gZWFybHkgdGltZS4gV2UgY2FuIGZpbmQgU1JBVCBlYXNpbHkgYnkgY29t
cGFyaW5nIHRoZSBzaWduYXR1cmUuDQo+ID4NCj4gPiBUaGlzIHBhdGNoIGFsc2UgcmVjb3JkIHNp
Z25hdHVyZSBhbmQgc29tZSBvdGhlciBpbmZvIGluDQo+ID4gYWNwaV9nYmxfcm9vdF90YWJsZV9s
aXN0IGF0IGVhcmx5IHRpbWUuDQoNCklmIHlvdSBoYXZlIGFkZHJlc3NlZCBteSBjb21tZW50cyBh
Z2FpbnN0IFBBVENIIDA1LCB5b3UgbmVlZG4ndCB0aGlzIHBhdGNoIGF0IGFsbC4NCg0KVGhhbmtz
IGFuZCBiZXN0IHJlZ2FyZHMNCi1Mdg0KDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBUYW5nIENo
ZW4gPHRhbmdjaGVuQGNuLmZ1aml0c3UuY29tPg0KPiA+IFJldmlld2VkLWJ5OiBaaGFuZyBZYW5m
ZWkgPHpoYW5neWFuZmVpQGNuLmZ1aml0c3UuY29tPg0KPiA+IC0tLQ0KPiA+ICBkcml2ZXJzL2Fj
cGkvYWNwaWNhL3RidXRpbHMuYyB8ICAgMjIgKysrKysrKysrKysrKysrKysrKysrKw0KPiA+ICAx
IGZpbGVzIGNoYW5nZWQsIDIyIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pDQo+ID4NCj4g
PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9hY3BpL2FjcGljYS90YnV0aWxzLmMgYi9kcml2ZXJzL2Fj
cGkvYWNwaWNhL3RidXRpbHMuYw0KPiANCj4gU2FtZSBhcyBwYXRjaCA1LzE4LiAgUGxlYXNlIGNo
YW5nZSB0aGUgdGl0bGUgdG8gIng4NiwgQUNQSUNBOiIuDQo+IEFkZGVkDQo+IEJvYi4NCj4gDQo+
IFRoYW5rcywNCj4gLVRvc2hpDQo+IA0KPiANCj4gPiBpbmRleCA5ZDY4ZmZjLi41ZDMxODg3IDEw
MDY0NA0KPiA+IC0tLSBhL2RyaXZlcnMvYWNwaS9hY3BpY2EvdGJ1dGlscy5jDQo+ID4gKysrIGIv
ZHJpdmVycy9hY3BpL2FjcGljYS90YnV0aWxzLmMNCj4gPiBAQCAtNjI3LDYgKzYyNyw3IEBADQo+
IGFjcGlfdGJfcGFyc2Vfcm9vdF90YWJsZShhY3BpX3BoeXNpY2FsX2FkZHJlc3MgcnNkcF9hZGRy
ZXNzKQ0KPiA+ICAJdTMyIGk7DQo+ID4gIAl1MzIgdGFibGVfY291bnQ7DQo+ID4gIAlzdHJ1Y3Qg
YWNwaV90YWJsZV9oZWFkZXIgKnRhYmxlOw0KPiA+ICsJc3RydWN0IGFjcGlfdGFibGVfZGVzYyAq
dGFibGVfZGVzYzsNCj4gPiAgCWFjcGlfcGh5c2ljYWxfYWRkcmVzcyBhZGRyZXNzOw0KPiA+ICAJ
YWNwaV9waHlzaWNhbF9hZGRyZXNzIHVuaW5pdGlhbGl6ZWRfdmFyKHJzZHRfYWRkcmVzcyk7DQo+
ID4gIAl1MzIgbGVuZ3RoOw0KPiA+IEBAIC03NjYsNiArNzY3LDI3IEBADQo+IGFjcGlfdGJfcGFy
c2Vfcm9vdF90YWJsZShhY3BpX3BoeXNpY2FsX2FkZHJlc3MgcnNkcF9hZGRyZXNzKQ0KPiA+ICAJ
ICovDQo+ID4gIAlhY3BpX29zX3VubWFwX21lbW9yeSh0YWJsZSwgbGVuZ3RoKTsNCj4gPg0KPiA+
ICsJLyoNCj4gPiArCSAqIEFsc28gaW5pdGlhbGl6ZSB0aGUgdGFibGUgZW50cmllcyBoZXJlLCBz
byB0aGF0IGxhdGVyIHdlIGNhbiB1c2UNCj4gdGhlbQ0KPiA+ICsJICogdG8gZmluZCBTUkFUIGF0
IHZlcnkgZXJhbHkgdGltZSB0byByZXNlcnZlIGhvdHBsdWdnYWJsZSBtZW1vcnkuDQo+ID4gKwkg
Ki8NCj4gPiArCWZvciAoaSA9IDI7IGkgPCBhY3BpX2dibF9yb290X3RhYmxlX2xpc3QuY3VycmVu
dF90YWJsZV9jb3VudDsgaSsrKSB7DQo+ID4gKwkJdGFibGUgPSBhY3BpX29zX21hcF9tZW1vcnko
DQo+ID4gKwkJCQlhY3BpX2dibF9yb290X3RhYmxlX2xpc3QudGFibGVzW2ldLmFkZHJlc3MsDQo+
ID4gKwkJCQlzaXplb2Yoc3RydWN0IGFjcGlfdGFibGVfaGVhZGVyKSk7DQo+ID4gKwkJaWYgKCF0
YWJsZSkNCj4gPiArCQkJcmV0dXJuX0FDUElfU1RBVFVTKEFFX05PX01FTU9SWSk7DQo+ID4gKw0K
PiA+ICsJCXRhYmxlX2Rlc2MgPSAmYWNwaV9nYmxfcm9vdF90YWJsZV9saXN0LnRhYmxlc1tpXTsN
Cj4gPiArDQo+ID4gKwkJdGFibGVfZGVzYy0+cG9pbnRlciA9IE5VTEw7DQo+ID4gKwkJdGFibGVf
ZGVzYy0+bGVuZ3RoID0gdGFibGUtPmxlbmd0aDsNCj4gPiArCQl0YWJsZV9kZXNjLT5mbGFncyA9
IEFDUElfVEFCTEVfT1JJR0lOX01BUFBFRDsNCj4gPiArCQlBQ1BJX01PVkVfMzJfVE9fMzIodGFi
bGVfZGVzYy0+c2lnbmF0dXJlLmFzY2lpLA0KPiB0YWJsZS0+c2lnbmF0dXJlKTsNCj4gPiArDQo+
ID4gKwkJYWNwaV9vc191bm1hcF9tZW1vcnkodGFibGUsIHNpemVvZihzdHJ1Y3QNCj4gYWNwaV90
YWJsZV9oZWFkZXIpKTsNCj4gPiArCX0NCj4gPiArDQo+ID4gIAlyZXR1cm5fQUNQSV9TVEFUVVMo
QUVfT0spOw0KPiA+ICB9DQo+ID4NCj4gDQo+IA0KPiAtLQ0KPiBUbyB1bnN1YnNjcmliZSBmcm9t
IHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtYWNwaSIgaW4NCj4g
dGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9tb0B2Z2VyLmtlcm5lbC5vcmcNCj4gTW9y
ZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5m
by5odG1sDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

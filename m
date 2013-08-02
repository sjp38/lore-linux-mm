Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 10F1F6B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 04:54:31 -0400 (EDT)
From: "Zheng, Lv" <lv.zheng@intel.com>
Subject: RE: [PATCH v2 05/18] x86, acpi: Split acpi_boot_table_init() into
 two parts.
Date: Fri, 2 Aug 2013 08:54:24 +0000
Message-ID: <1AE640813FDE7649BE1B193DEA596E8802437C78@SHSMSX101.ccr.corp.intel.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
  <1375340800-19332-6-git-send-email-tangchen@cn.fujitsu.com>
 <1375399931.10300.36.camel@misato.fc.hp.com>
 <1AE640813FDE7649BE1B193DEA596E8802437AC8@SHSMSX101.ccr.corp.intel.com>
 <51FB5948.6080802@cn.fujitsu.com>
 <1AE640813FDE7649BE1B193DEA596E8802437C47@SHSMSX101.ccr.corp.intel.com>
 <51FB6DE6.6040200@cn.fujitsu.com>
In-Reply-To: <51FB6DE6.6040200@cn.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Toshi Kani <toshi.kani@hp.com>, "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tj@kernel.org" <tj@kernel.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Moore, Robert" <robert.moore@intel.com>

PiBGcm9tOiBUYW5nIENoZW4gW21haWx0bzp0YW5nY2hlbkBjbi5mdWppdHN1LmNvbV0NCj4gU2Vu
dDogRnJpZGF5LCBBdWd1c3QgMDIsIDIwMTMgNDoyOSBQTQ0KPiANCj4gT24gMDgvMDIvMjAxMyAw
NDoyMyBQTSwgWmhlbmcsIEx2IHdyb3RlOg0KPiAuLi4uLi4NCj4gPj4gQWNjb3JkaW5nIHRvIHdo
YXQgeW91J3ZlIGV4cGxhaW5lZCwgd2hhdCB5b3UgZGlkbuKAmXQgd2FudCB0byBiZQ0KPiBjYWxs
ZWQNCj4gPj4gZWFybGllciBpcyBleGFjdGx5ICJhY3BpIGluaXRyZCB0YWJsZSBvdmVycmlkZSIs
IHBsZWFzZSBzcGxpdCBvbmx5IHRoaXMgbG9naWMNCj4gdG8NCj4gPj4gdGhlIHN0ZXAgMiBhbmQg
bGVhdmUgdGhlIG90aGVycyByZW1haW5lZC4NCj4gPj4gSSB0aGluayB5b3Ugc2hvdWxkIHdyaXRl
IGEgZnVuY3Rpb24gbmFtZWQgYXMgYWNwaV9vdmVycmlkZV90YWJsZXMoKSBvcg0KPiA+PiBsaWtl
d2lzZSBpbiB0YnhmYWNlLmMgdG8gYmUgZXhlY3V0ZWQgYXMgdGhlIE9TUE0gZW50cnkgb2YgdGhl
IHN0ZXAgMi4NCj4gPj4gSW5zaWRlIHRoaXMgZnVuY3Rpb24sIGFjcGlfdGJfdGFibGVfb3ZlcnJp
ZGUoKSBzaG91bGQgYmUgY2FsbGVkLg0KPiAuLi4uLi4NCj4gDQo+IE9LLCBJIHVuZGVyc3RhbmQg
d2hhdCB5b3UgYXJlIHN1Z2dlc3Rpbmcgbm93LiBJdCBpcyByZWFzb25hYmxlLg0KPiBJJ2xsIHVw
ZGF0ZSB0aGUgcGF0Y2gtc2V0IGluIHRoZSBuZXh0IHZlcnNpb24uDQo+IA0KPiBCdXQgdG9kYXks
IEkganVzdCByZWJhc2VkIGl0IHRvIHRoZSBsYXRlc3Qga2VybmVsLiBJJ2xsIHJlc2VuZCB0aGlz
DQo+IHJlYmFzZWQgdjIgcGF0Y2gtc2V0IHNvIHRoYXQgVGogYW5kIG90aGVyIGd1eXMgY2FuIHJl
dmlldyBpdC4NCj4gDQo+IEknbGwgaW5jbHVkZSBhbGwgb2YgeW91ciBjb21tZW50cyBpbiB0aGUg
djMgcGF0Y2gtc2V0LiBUaGFuayB5b3UgdmVyeQ0KPiBtdWNoLiA6KQ0KDQpJZiB0aGUgcmV2aWV3
IHByb2Nlc3MgdGFrZXMgbG9uZ2VyIHRpbWUsIHlvdSBjb3VsZCBhbHNvIGxldCBBQ1BJQ0EgZm9s
a3MgdG8gZG8gdGhpcyBmaXJzdCBpbiBBQ1BJQ0EsIHlvdSdsbCBmaW5kIHRoZSBjb21taXQgaW4g
dGhlIG5leHQgcmVsZWFzZSBjeWNsZS4NCkluIHRoaXMgd2F5LCB0aGVyZSB3b24ndCBiZSBzb3Vy
Y2UgY29kZSBkaXZlcmdlbmNlcyBiZXR3ZWVuIExpbnV4IGFuZCBBQ1BJQ0EuDQoNClRoYW5rcw0K
LUx2DQoNCj4gDQo+IFRoYW5rcy4NCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

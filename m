Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CB7166B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 21:35:06 -0400 (EDT)
Message-ID: <51FF00EC.1030609@cn.fujitsu.com>
Date: Mon, 05 Aug 2013 09:33:32 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 RESEND 07/18] x86, ACPI: Also initialize signature
 and length when parsing root table.
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com> <1375434877-20704-8-git-send-email-tangchen@cn.fujitsu.com> <3299662.WAS8YLIUlv@vostro.rjw.lan>
In-Reply-To: <3299662.WAS8YLIUlv@vostro.rjw.lan>
Content-Type: multipart/mixed;
 boundary="------------050205050209030200080600"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This is a multi-part message in MIME format.
--------------050205050209030200080600
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed

Hi Rafael,

On 08/02/2013 09:03 PM, Rafael J. Wysocki wrote:
> On Friday, August 02, 2013 05:14:26 PM Tang Chen wrote:
>> Besides the phys addr of the acpi tables, it will be very convenient if
>> we also have the signature of each table in acpi_gbl_root_table_list at
>> early time. We can find SRAT easily by comparing the signature.
>>
>> This patch alse record signature and some other info in
>> acpi_gbl_root_table_list at early time.
>>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> Reviewed-by: Zhang Yanfei<zhangyanfei@cn.fujitsu.com>
>
> The subject is misleading, as the change is in ACPICA and therefore affects not
> only x86.

OK, will change it.

>
> Also I think the same comments as for the other ACPICA patch is this series
> applies: You shouldn't modify acpi_tbl_parse_root_table() in ways that would
> require the other OSes using ACPICA to be modified.
>

Thank you for the reminding. Please refer to the attachment.
How do you think of the idea from Zheng ?

Thanks.

--------------050205050209030200080600
Content-Transfer-Encoding: 7bit
Content-Type: message/rfc822;
 name="Re: [PATCH v2 05_18] x86, acpi: Split acpi_boot_table_init() into two parts..eml"
Content-Disposition: attachment;
 filename*0="Re: [PATCH v2 05_18] x86, acpi: Split acpi_boot_table_init()";
 filename*1=" into two parts..eml"

Content-Transfer-Encoding: base64
X-Account-Key: account1
X-Mozilla-Keys: $label1                                                                         
Received: from edo.cn.fujitsu.com ([10.167.33.5])
          by fnstmail02.fnst.cn.fujitsu.com (Lotus Domino Release 8.5.3)
          with ESMTP id 2013080216101235-361118 ;
          Fri, 2 Aug 2013 16:10:12 +0800
Received: from heian.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by edo.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id r728BRPO032041;
	Fri, 2 Aug 2013 16:11:27 +0800
Received: from mga14.intel.com ([143.182.124.37])
  by heian.cn.fujitsu.com with ESMTP; 02 Aug 2013 16:09:46 +0800
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by azsmga102.ch.intel.com with ESMTP; 02 Aug 2013 01:11:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="4.89,799,1367996400";
   d="scan'208";a="375023522"
Received: from fmsmsx106.amr.corp.intel.com ([10.19.9.37])
  by fmsmga001.fm.intel.com with ESMTP; 02 Aug 2013 01:11:17 -0700
Received: from fmsmsx154.amr.corp.intel.com (10.18.116.70) by
 FMSMSX106.amr.corp.intel.com (10.19.9.37) with Microsoft SMTP Server (TLS) id
 14.3.123.3; Fri, 2 Aug 2013 01:11:17 -0700
Received: from shsmsx102.ccr.corp.intel.com (10.239.4.154) by
 FMSMSX154.amr.corp.intel.com (10.18.116.70) with Microsoft SMTP Server (TLS)
 id 14.3.123.3; Fri, 2 Aug 2013 01:11:17 -0700
Received: from shsmsx101.ccr.corp.intel.com ([169.254.1.99]) by
 SHSMSX102.ccr.corp.intel.com ([169.254.2.81]) with mapi id 14.03.0123.003;
 Fri, 2 Aug 2013 16:11:15 +0800
From: "Zheng, Lv" <lv.zheng@intel.com>
To: Tang Chen <tangchen@cn.fujitsu.com>
CC: Toshi Kani <toshi.kani@hp.com>, "rjw@sisk.pl" <rjw@sisk.pl>,
        "lenb@kernel.org" <lenb@kernel.org>,
        "tglx@linutronix.de"
	<tglx@linutronix.de>,
        "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com"
	<hpa@zytor.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "tj@kernel.org" <tj@kernel.org>, "trenn@suse.de" <trenn@suse.de>,
        "yinghai@kernel.org" <yinghai@kernel.org>,
        "jiang.liu@huawei.com"
	<jiang.liu@huawei.com>,
        "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>,
        "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>,
        "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>,
        "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>,
        "mgorman@suse.de"
	<mgorman@suse.de>,
        "minchan@kernel.org" <minchan@kernel.org>,
        "mina86@mina86.com" <mina86@mina86.com>,
        "gong.chen@linux.intel.com"
	<gong.chen@linux.intel.com>,
        "vasilis.liaskovitis@profitbricks.com"
	<vasilis.liaskovitis@profitbricks.com>,
        "lwoodman@redhat.com"
	<lwoodman@redhat.com>,
        "riel@redhat.com" <riel@redhat.com>,
        "jweiner@redhat.com" <jweiner@redhat.com>,
        "prarit@redhat.com"
	<prarit@redhat.com>,
        "zhangyanfei@cn.fujitsu.com"
	<zhangyanfei@cn.fujitsu.com>,
        "yanghy@cn.fujitsu.com"
	<yanghy@cn.fujitsu.com>,
        "x86@kernel.org" <x86@kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-acpi@vger.kernel.org"
	<linux-acpi@vger.kernel.org>,
        "Moore, Robert" <robert.moore@intel.com>
Subject: RE: [PATCH v2 05/18] x86, acpi: Split acpi_boot_table_init() into
 two parts.
Thread-Topic: [PATCH v2 05/18] x86, acpi: Split acpi_boot_table_init() into
 two parts.
Thread-Index: AQHOjoaq7VOPC5wsY06gQsg+OI/gRpmAe4eAgADlMFD//5hXAIAAkoKQ
Date: Fri, 2 Aug 2013 08:11:15 +0000
Message-ID: <1AE640813FDE7649BE1B193DEA596E8802437C27@SHSMSX101.ccr.corp.intel.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
  <1375340800-19332-6-git-send-email-tangchen@cn.fujitsu.com>
 <1375399931.10300.36.camel@misato.fc.hp.com>
 <1AE640813FDE7649BE1B193DEA596E8802437AC8@SHSMSX101.ccr.corp.intel.com>
 <51FB5948.6080802@cn.fujitsu.com>
In-Reply-To: <51FB5948.6080802@cn.fujitsu.com>
Accept-Language: zh-CN, en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.239.127.40]
MIME-Version: 1.0
X-MIMETrack: Itemize by SMTP Server on mailserver/fnst(Release 8.5.3|September 15, 2011) at
 2013/08/02 16:10:12,
	Serialize by POP3 Server on mailserver/fnst(Release 8.5.3|September 15, 2011) at
 2013/08/02 16:15:47,
	Serialize complete at 2013/08/02 16:15:47
X-Notes-Item: 2F32E130:12322441-68900C14:BF435236;
 type=4; name=$REF
X-Notes-Item: 7D42B491:7CB6D2DF-F0748EE8:9EB946E9;
 type=4; name=$INetOrig
X-Notes-Item: Fri, 2 Aug 2013 08:11:15 +0000;
 type=400; name=$Created
X-Notes-Item: Memo;
 name=Form
X-Notes-Item: CN=mailserver/O=fnst;
 type=501; flags=44; name=$UpdatedBy
X-Notes-Item: CA7CDA8B:2FD73949-48257BBB:002CE144;
 type=4; name=$Orig
X-Notes-Item: ;
 type=501; name=Categories
X-Notes-Item: ;
 type=401; name=$Revisions
X-Notes-Item: CN=mailserver/O=fnst;
 type=501; flags=0; name=RouteServers
X-Notes-Item: 02-Aug-2013 16:10:12 ZE8/02-Aug-2013 16:10:12 ZE8;
 type=401; flags=0; name=RouteTimes
X-Notes-Item: Fri, 2 Aug 2013 16:10:12 +0800;
 type=400; name=DeliveredDate
X-Notes-Item: =?UTF-8?B?PiBGcm9tOiBUYW5nIENoZW4gW21haWx0bzp0YW5nY2hlbkBjbi5mdWppdHN1?=
 =?UTF-8?B?LmNvbV0gPiBTZW50OiBGcmlkYXksIEF1Z3VzdCAwMiwgMjAxMyAzOjAxIFBN?=;
 flags=6; name=$Abstract
X-Notes-Item: 2F32E130:12322441-68900C14:BF435236, 2F32E130:12322441-68900C14:BF435236;
 type=4; name=$TUA
X-Notes-Item: 1;
 name=$NoteHasNativeMIME
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US

PiBGcm9tOiBUYW5nIENoZW4gW21haWx0bzp0YW5nY2hlbkBjbi5mdWppdHN1LmNvbV0NCj4gU2Vu
dDogRnJpZGF5LCBBdWd1c3QgMDIsIDIwMTMgMzowMSBQTQ0KPiANCj4gT24gMDgvMDIvMjAxMyAw
MToyNSBQTSwgWmhlbmcsIEx2IHdyb3RlOg0KPiAuLi4uLi4NCj4gPj4+IGluZGV4IGNlM2Q1ZGIu
LjlkNjhmZmMgMTAwNjQ0DQo+ID4+PiAtLS0gYS9kcml2ZXJzL2FjcGkvYWNwaWNhL3RidXRpbHMu
Yw0KPiA+Pj4gKysrIGIvZHJpdmVycy9hY3BpL2FjcGljYS90YnV0aWxzLmMNCj4gPj4+IEBAIC03
NjYsOSArNzY2LDMwIEBADQo+ID4+IGFjcGlfdGJfcGFyc2Vfcm9vdF90YWJsZShhY3BpX3BoeXNp
Y2FsX2FkZHJlc3MgcnNkcF9hZGRyZXNzKQ0KPiA+Pj4gICAJKi8NCj4gPj4+ICAgCWFjcGlfb3Nf
dW5tYXBfbWVtb3J5KHRhYmxlLCBsZW5ndGgpOw0KPiA+Pj4NCj4gPj4+ICsJcmV0dXJuX0FDUElf
U1RBVFVTKEFFX09LKTsNCj4gPj4+ICt9DQo+ID4+PiArDQo+ID4+Pg0KPiA+DQo+ID4gSSBkb24n
dCB0aGluayB5b3UgY2FuIHNwbGl0IHRoZSBmdW5jdGlvbiBoZXJlLg0KPiA+IEFDUElDQSBzdGls
bCBuZWVkIHRvIGNvbnRpbnVlIHRvIHBhcnNlIHRoZSB0YWJsZSB1c2luZyB0aGUgbG9naWMNCj4g
aW1wbGVtZW50ZWQgaW4gdGhlIGFjcGlfdGJfaW5zdGFsbF90YWJsZSgpIGFuZCBhY3BpX3RiX3Bh
cnNlX2ZhZHQoKS4NCj4gKGZvciBleGFtcGxlLCBlbmRpYW5lc3Mgb2YgdGhlIHNpZ25hdHVyZSku
DQo+ID4gWW91J2QgYmV0dGVyIHRvIGtlZXAgdGhlbSBhcyBpcyBhbmQgc3BsaXQgc29tZSBjb2Rl
cyBmcm9tDQo+ICdhY3BpX3RiX2luc3RhbGxfdGFibGUnIHRvIGZvcm0gYW5vdGhlciBmdW5jdGlv
bjoNCj4gYWNwaV90Yl9vdmVycmlkZV90YWJsZSgpLg0KPiANCj4gSSdtIHNvcnJ5LCBJIGRvbid0
IHF1aXRlIGZvbGxvdyB0aGlzLg0KPiANCj4gSSBzcGxpdCBhY3BpX3RiX3BhcnNlX3Jvb3RfdGFi
bGUoKSwgbm90IGFjcGlfdGJfaW5zdGFsbF90YWJsZSgpIGFuZA0KPiBhY3BpX3RiX3BhcnNlX2Zh
ZHQoKS4NCj4gSWYgQUNQSUNBIHdhbnRzIHRvIHVzZSB0aGVzZSB0d28gZnVuY3Rpb25zIHNvbWV3
aGVyZSBlbHNlLCBJIHRoaW5rIGl0IGlzDQo+IE9LLCBpc24ndCBpdD8NCj4gDQo+IEFuZCB0aGUg
cmVhc29uIEkgZGlkIHRoaXMsIHBsZWFzZSBzZWUgYmVsb3cuDQo+IA0KPiAuLi4uLi4NCj4gPj4+
ICsgKg0KPiA+Pj4gKyAqIEZVTkNUSU9OOiAgICBhY3BpX3RiX2luc3RhbGxfcm9vdF90YWJsZQ0K
PiA+DQo+ID4gSSB0aGluayB0aGlzIGZ1bmN0aW9uIHNob3VsZCBiZSBhY3BpX3RiX292ZXJyaWRl
X3RhYmxlcywgYW5kIGNhbGwNCj4gYWNwaV90Yl9vdmVycmlkZV90YWJsZSgpIGluc2lkZSB0aGlz
IGZ1bmN0aW9uIGZvciBlYWNoIHRhYmxlLg0KPiANCj4gSXQgaXMgbm90IGp1c3QgYWJvdXQgYWNw
aSBpbml0cmQgdGFibGUgb3ZlcnJpZGUuDQo+IA0KPiBhY3BpX3RiX3BhcnNlX3Jvb3RfdGFibGUo
KSB3YXMgc3BsaXQgaW50byB0d28gc3RlcHM6DQo+IDEuIGluaXRpYWxpemUgYWNwaV9nYmxfcm9v
dF90YWJsZV9saXN0DQo+IDIuIGluc3RhbGwgdGFibGVzIGludG8gYWNwaV9nYmxfcm9vdF90YWJs
ZV9saXN0DQo+IA0KPiBJIG5lZWQgc3RlcDEgZWFybGllciBiZWNhdXNlIEkgd2FudCB0byBmaW5k
IFNSQVQgYXQgZWFybHkgdGltZS4NCj4gQnV0IEkgZG9uJ3Qgd2FudCBzdGVwMiBlYXJsaWVyIGJl
Y2F1c2UgYmVmb3JlIGluc3RhbGwgdGhlIHRhYmxlcyBpbg0KPiBmaXJtd2FyZSwNCj4gYWNwaSBp
bml0cmQgdGFibGUgb3ZlcnJpZGUgY291bGQgaGFwcGVuLiBJIHdhbnQgb25seSBTUkFULCBJIGRv
bid0IHdhbnQgdG8NCj4gdG91Y2ggbXVjaCBleGlzdGluZyBjb2RlLg0KDQpBY2NvcmRpbmcgdG8g
d2hhdCB5b3UndmUgZXhwbGFpbmVkLCB3aGF0IHlvdSBkaWRu4oCZdCB3YW50IHRvIGJlIGNhbGxl
ZCBlYXJsaWVyIGlzIGV4YWN0bHkgImFjcGkgaW5pdHJkIHRhYmxlIG92ZXJyaWRlIiwgcGxlYXNl
IHNwbGl0IG9ubHkgdGhpcyBsb2dpYyB0byB0aGUgc3RlcCAyIGFuZCBsZWF2ZSB0aGUgb3RoZXJz
IHJlbWFpbmVkLg0KSSB0aGluayB5b3Ugc2hvdWxkIHdyaXRlIGEgZnVuY3Rpb24gbmFtZWQgYXMg
YWNwaV9vdmVycmlkZV90YWJsZXMoKSBvciBsaWtld2lzZSBpbiB0YnhmYWNlLmMgdG8gYmUgZXhl
Y3V0ZWQgYXMgdGhlIE9TUE0gZW50cnkgb2YgdGhlIHN0ZXAgMi4NCkluc2lkZSB0aGlzIGZ1bmN0
aW9uLCBhY3BpX3RiX3RhYmxlX292ZXJyaWRlKCkgc2hvdWxkIGJlIGNhbGxlZC4NCg0KMjY4IHZv
aWQNCjI2OSBhY3BpX3RiX2luc3RhbGxfdGFibGUoYWNwaV9waHlzaWNhbF9hZGRyZXNzIGFkZHJl
c3MsDQoyNzAgICAgICAgICAgICAgICAgICAgICAgIGNoYXIgKnNpZ25hdHVyZSwgdTMyIHRhYmxl
X2luZGV4KQ0KMjcxIHsNCg0KSSB0aGluayB5b3Ugc3RpbGwgbmVlZCB0aGUgZm9sbG93aW5nIGNv
ZGVzIHRvIGJlIGNhbGxlZCBhdCB0aGUgZWFybHkgc3RhZ2UuDQoNCjI3MiAgICAgICAgIHN0cnVj
dCBhY3BpX3RhYmxlX2hlYWRlciAqdGFibGU7DQoyNzMgICAgICAgICBzdHJ1Y3QgYWNwaV90YWJs
ZV9oZWFkZXIgKmZpbmFsX3RhYmxlOw0KMjc0ICAgICAgICAgc3RydWN0IGFjcGlfdGFibGVfZGVz
YyAqdGFibGVfZGVzYzsNCjI3NSANCjI3NiAgICAgICAgIGlmICghYWRkcmVzcykgew0KMjc3ICAg
ICAgICAgICAgICAgICBBQ1BJX0VSUk9SKChBRV9JTkZPLA0KMjc4ICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAiTnVsbCBwaHlzaWNhbCBhZGRyZXNzIGZvciBBQ1BJIHRhYmxlIFslc10iLA0K
Mjc5ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzaWduYXR1cmUpKTsNCjI4MCAgICAgICAg
ICAgICAgICAgcmV0dXJuOw0KMjgxICAgICAgICAgfQ0KMjgyIA0KMjgzICAgICAgICAgLyogTWFw
IGp1c3QgdGhlIHRhYmxlIGhlYWRlciAqLw0KMjg0IA0KMjg1ICAgICAgICAgdGFibGUgPSBhY3Bp
X29zX21hcF9tZW1vcnkoYWRkcmVzcywgc2l6ZW9mKHN0cnVjdCBhY3BpX3RhYmxlX2hlYWRlcikp
Ow0KMjg2ICAgICAgICAgaWYgKCF0YWJsZSkgew0KMjg3ICAgICAgICAgICAgICAgICBBQ1BJX0VS
Uk9SKChBRV9JTkZPLA0KMjg4ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiQ291bGQgbm90
IG1hcCBtZW1vcnkgZm9yIHRhYmxlIFslc10gYXQgJXAiLA0KMjg5ICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICBzaWduYXR1cmUsIEFDUElfQ0FTVF9QVFIodm9pZCwgYWRkcmVzcykpKTsNCjI5
MCAgICAgICAgICAgICAgICAgcmV0dXJuOw0KMjkxICAgICAgICAgfQ0KMjkyIA0KMjkzICAgICAg
ICAgLyogSWYgYSBwYXJ0aWN1bGFyIHNpZ25hdHVyZSBpcyBleHBlY3RlZCAoRFNEVC9GQUNTKSwg
aXQgbXVzdCBtYXRjaCAqLw0KMjk0IA0KMjk1ICAgICAgICAgaWYgKHNpZ25hdHVyZSAmJiAhQUNQ
SV9DT01QQVJFX05BTUUodGFibGUtPnNpZ25hdHVyZSwgc2lnbmF0dXJlKSkgew0KMjk2ICAgICAg
ICAgICAgICAgICBBQ1BJX0JJT1NfRVJST1IoKEFFX0lORk8sDQoyOTcgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIkludmFsaWQgc2lnbmF0dXJlIDB4JVggZm9yIEFDUEkgdGFibGUs
IGV4cGVjdGVkIFslc10iLA0KMjk4ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICpB
Q1BJX0NBU1RfUFRSKHUzMiwgdGFibGUtPnNpZ25hdHVyZSksDQoyOTkgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgc2lnbmF0dXJlKSk7DQozMDAgICAgICAgICAgICAgICAgIGdvdG8g
dW5tYXBfYW5kX2V4aXQ7DQozMDEgICAgICAgICB9DQozMDIgDQozMDMgICAgICAgICAvKg0KMzA0
ICAgICAgICAgICogSW5pdGlhbGl6ZSB0aGUgdGFibGUgZW50cnkuIFNldCB0aGUgcG9pbnRlciB0
byBOVUxMLCBzaW5jZSB0aGUNCjMwNSAgICAgICAgICAqIHRhYmxlIGlzIG5vdCBmdWxseSBtYXBw
ZWQgYXQgdGhpcyB0aW1lLg0KMzA2ICAgICAgICAgICovDQozMDcgICAgICAgICB0YWJsZV9kZXNj
ID0gJmFjcGlfZ2JsX3Jvb3RfdGFibGVfbGlzdC50YWJsZXNbdGFibGVfaW5kZXhdOw0KMzA4IA0K
MzA5ICAgICAgICAgdGFibGVfZGVzYy0+YWRkcmVzcyA9IGFkZHJlc3M7DQozMTAgICAgICAgICB0
YWJsZV9kZXNjLT5wb2ludGVyID0gTlVMTDsNCjMxMSAgICAgICAgIHRhYmxlX2Rlc2MtPmxlbmd0
aCA9IHRhYmxlLT5sZW5ndGg7DQozMTIgICAgICAgICB0YWJsZV9kZXNjLT5mbGFncyA9IEFDUElf
VEFCTEVfT1JJR0lOX01BUFBFRDsNCjMxMyAgICAgICAgIEFDUElfTU9WRV8zMl9UT18zMih0YWJs
ZV9kZXNjLT5zaWduYXR1cmUuYXNjaWksIHRhYmxlLT5zaWduYXR1cmUpOw0KMzE0IA0KDQpZb3Ug
c2hvdWxkIGRlbGV0ZSB0aGUgZm9sbG93aW5nIGNvZGVzOg0KDQozMTUgICAgICAgICAvKg0KMzE2
ICAgICAgICAgICogQUNQSSBUYWJsZSBPdmVycmlkZToNCjMxNyAgICAgICAgICAqDQozMTggICAg
ICAgICAgKiBCZWZvcmUgd2UgaW5zdGFsbCB0aGUgdGFibGUsIGxldCB0aGUgaG9zdCBPUyBvdmVy
cmlkZSBpdCB3aXRoIGEgbmV3DQozMTkgICAgICAgICAgKiBvbmUgaWYgZGVzaXJlZC4gQW55IHRh
YmxlIHdpdGhpbiB0aGUgUlNEVC9YU0RUIGNhbiBiZSByZXBsYWNlZCwNCjMyMCAgICAgICAgICAq
IGluY2x1ZGluZyB0aGUgRFNEVCB3aGljaCBpcyBwb2ludGVkIHRvIGJ5IHRoZSBGQURULg0KMzIx
ICAgICAgICAgICoNCjMyMiAgICAgICAgICAqIE5PVEU6IElmIHRoZSB0YWJsZSBpcyBvdmVycmlk
ZGVuLCB0aGVuIGZpbmFsX3RhYmxlIHdpbGwgY29udGFpbiBhDQozMjMgICAgICAgICAgKiBtYXBw
ZWQgcG9pbnRlciB0byB0aGUgZnVsbCBuZXcgdGFibGUuIElmIHRoZSB0YWJsZSBpcyBub3Qgb3Zl
cnJpZGRlbiwNCjMyNCAgICAgICAgICAqIG9yIGlmIHRoZXJlIGhhcyBiZWVuIGEgcGh5c2ljYWwg
b3ZlcnJpZGUsIHRoZW4gdGhlIHRhYmxlIHdpbGwgYmUNCjMyNSAgICAgICAgICAqIGZ1bGx5IG1h
cHBlZCBsYXRlciAoaW4gdmVyaWZ5IHRhYmxlKS4gSW4gYW55IGNhc2UsIHdlIG11c3QNCjMyNiAg
ICAgICAgICAqIHVubWFwIHRoZSBoZWFkZXIgdGhhdCB3YXMgbWFwcGVkIGFib3ZlLg0KMzI3ICAg
ICAgICAgICovDQozMjggICAgICAgICBmaW5hbF90YWJsZSA9IGFjcGlfdGJfdGFibGVfb3ZlcnJp
ZGUodGFibGUsIHRhYmxlX2Rlc2MpOw0KMzI5ICAgICAgICAgaWYgKCFmaW5hbF90YWJsZSkgew0K
MzMwICAgICAgICAgICAgICAgICBmaW5hbF90YWJsZSA9IHRhYmxlOyAgICAvKiBUaGVyZSB3YXMg
bm8gb3ZlcnJpZGUgKi8NCjMzMSAgICAgICAgIH0NCjMzMiANCg0KWW91IHN0aWxsIG5lZWQgdG8g
a2VlcCB0aGUgZm9sbG93aW5nIGxvZ2ljLg0KDQozMzMgICAgICAgICBhY3BpX3RiX3ByaW50X3Rh
YmxlX2hlYWRlcih0YWJsZV9kZXNjLT5hZGRyZXNzLCBmaW5hbF90YWJsZSk7DQozMzQgDQozMzUg
ICAgICAgICAvKiBTZXQgdGhlIGdsb2JhbCBpbnRlZ2VyIHdpZHRoIChiYXNlZCB1cG9uIHJldmlz
aW9uIG9mIHRoZSBEU0RUKSAqLw0KMzM2IA0KMzM3ICAgICAgICAgaWYgKHRhYmxlX2luZGV4ID09
IEFDUElfVEFCTEVfSU5ERVhfRFNEVCkgew0KMzM4ICAgICAgICAgICAgICAgICBhY3BpX3V0X3Nl
dF9pbnRlZ2VyX3dpZHRoKGZpbmFsX3RhYmxlLT5yZXZpc2lvbik7DQozMzkgICAgICAgICB9DQoz
NDAgDQoNCllvdSBzaG91bGQgZGVsZXRlIHRoZSBmb2xsb3dpbmcgY29kZXM6DQoNCjM0MSAgICAg
ICAgIC8qDQozNDIgICAgICAgICAgKiBJZiB3ZSBoYXZlIGEgcGh5c2ljYWwgb3ZlcnJpZGUgZHVy
aW5nIHRoaXMgZWFybHkgbG9hZGluZyBvZiB0aGUgQUNQSQ0KMzQzICAgICAgICAgICogdGFibGVz
LCB1bm1hcCB0aGUgdGFibGUgZm9yIG5vdy4gSXQgd2lsbCBiZSBtYXBwZWQgYWdhaW4gbGF0ZXIg
d2hlbg0KMzQ0ICAgICAgICAgICogaXQgaXMgYWN0dWFsbHkgdXNlZC4gVGhpcyBzdXBwb3J0cyB2
ZXJ5IGVhcmx5IGxvYWRpbmcgb2YgQUNQSSB0YWJsZXMsDQozNDUgICAgICAgICAgKiBiZWZvcmUg
dmlydHVhbCBtZW1vcnkgaXMgZnVsbHkgaW5pdGlhbGl6ZWQgYW5kIHJ1bm5pbmcgd2l0aGluIHRo
ZQ0KMzQ2ICAgICAgICAgICogaG9zdCBPUy4gTm90ZTogQSBsb2dpY2FsIG92ZXJyaWRlIGhhcyB0
aGUgQUNQSV9UQUJMRV9PUklHSU5fT1ZFUlJJREUNCjM0NyAgICAgICAgICAqIGZsYWcgc2V0IGFu
ZCB3aWxsIG5vdCBiZSBkZWxldGVkIGJlbG93Lg0KMzQ4ICAgICAgICAgICovDQozNDkgICAgICAg
ICBpZiAoZmluYWxfdGFibGUgIT0gdGFibGUpIHsNCjM1MCAgICAgICAgICAgICAgICAgYWNwaV90
Yl9kZWxldGVfdGFibGUodGFibGVfZGVzYyk7DQozNTEgICAgICAgICB9DQoNCktlZXAgdGhlIGZv
bGxvd2luZy4NCg0KMzUyIA0KMzUzICAgICAgIHVubWFwX2FuZF9leGl0Og0KMzU0IA0KMzU1ICAg
ICAgICAgLyogQWx3YXlzIHVubWFwIHRoZSB0YWJsZSBoZWFkZXIgdGhhdCB3ZSBtYXBwZWQgYWJv
dmUgKi8NCjM1NiANCjM1NyAgICAgICAgIGFjcGlfb3NfdW5tYXBfbWVtb3J5KHRhYmxlLCBzaXpl
b2Yoc3RydWN0IGFjcGlfdGFibGVfaGVhZGVyKSk7DQozNTggfQ0KDQpJJ20gbm90IHN1cmUgaWYg
dGhpcyBjYW4gbWFrZSBteSBjb25jZXJucyBjbGVhcmVyIGZvciB5b3Ugbm93Lg0KDQpUaGFua3Mg
YW5kIGJlc3QgcmVnYXJkcw0KLUx2DQoNCj4gDQo+IFdvdWxkIHlvdSBwbGVhc2UgZXhwbGFpbiBt
b3JlIGFib3V0IHlvdXIgY29tbWVudCA/IEkgdGhpbmsgbWF5YmUgSQ0KPiBtaXNzZWQgc29tZXRo
aW5nDQo+IGltcG9ydGFudCB0byB5b3UgZ3V5cy4gOikNCj4gDQo+IEFuZCBhbGwgdGhlIG90aGVy
IEFDUElDQSBydWxlcyB3aWxsIGJlIGZvbGxvd2VkIGluIHRoZSBuZXh0IHZlcnNpb24uDQo+IA0K
PiBUaGFua3MuDQo=


--------------050205050209030200080600--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

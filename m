Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 187ED6B0007
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 15:02:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u65so26026pfd.7
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 12:02:53 -0800 (PST)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id 2-v6si2713043ple.387.2018.02.27.12.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 12:02:51 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: =?utf-8?B?UmU6IOetlOWkjTogW1JGQyBwYXRjaF0gaW9yZW1hcDogZG9uJ3Qgc2V0IHVw?=
 =?utf-8?Q?_huge_I/O_mappings_when_p4d/pud/pmd_is_zero?=
Date: Tue, 27 Feb 2018 20:02:45 +0000
Message-ID: <1519764469.2693.4.camel@hpe.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
	 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
	 <1519175992.16384.121.camel@hpe.com>
	 <etPan.5a8d2180.1dbfd272.49b8@localhost> <20180221115758.GA7614@arm.com>
	 <32c9b1c3-086b-ba54-f9e9-aefa50066730@huawei.com>
	 <20180226110422.GD8736@arm.com>
	 <a80e540f-f3bd-53da-185d-7fffe801f10c@huawei.com>
	 <1519763686.2693.2.camel@hpe.com> <20180227195919.GA5348@arm.com>
In-Reply-To: <20180227195919.GA5348@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7BCEFCFBAAFC745ADBC6D3239EFFEBE@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <mhocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

T24gVHVlLCAyMDE4LTAyLTI3IGF0IDE5OjU5ICswMDAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
T24gVHVlLCBGZWIgMjcsIDIwMTggYXQgMDc6NDk6NDJQTSArMDAwMCwgS2FuaSwgVG9zaGkgd3Jv
dGU6DQo+ID4gT24gTW9uLCAyMDE4LTAyLTI2IGF0IDIwOjUzICswODAwLCBIYW5qdW4gR3VvIHdy
b3RlOg0KPiA+ID4gT24gMjAxOC8yLzI2IDE5OjA0LCBXaWxsIERlYWNvbiB3cm90ZToNCj4gPiA+
ID4gT24gTW9uLCBGZWIgMjYsIDIwMTggYXQgMDY6NTc6MjBQTSArMDgwMCwgSGFuanVuIEd1byB3
cm90ZToNCj4gPiA+ID4gPiBTaW1wbHkgZG8gc29tZXRoaW5nIGJlbG93IGF0IG5vdyAoYmVmb3Jl
IHRoZSBicm9rZW4gY29kZSBpcyBmaXhlZCk/DQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gZGlmZiAt
LWdpdCBhL2FyY2gvYXJtNjQvS2NvbmZpZyBiL2FyY2gvYXJtNjQvS2NvbmZpZw0KPiA+ID4gPiA+
IGluZGV4IGIyYjk1ZjcuLmE4NjE0OGMgMTAwNjQ0DQo+ID4gPiA+ID4gLS0tIGEvYXJjaC9hcm02
NC9LY29uZmlnDQo+ID4gPiA+ID4gKysrIGIvYXJjaC9hcm02NC9LY29uZmlnDQo+ID4gPiA+ID4g
QEAgLTg0LDcgKzg0LDYgQEAgY29uZmlnIEFSTTY0DQo+ID4gPiA+ID4gICAgICAgICBzZWxlY3Qg
SEFWRV9BTElHTkVEX1NUUlVDVF9QQUdFIGlmIFNMVUINCj4gPiA+ID4gPiAgICAgICAgIHNlbGVj
dCBIQVZFX0FSQ0hfQVVESVRTWVNDQUxMDQo+ID4gPiA+ID4gICAgICAgICBzZWxlY3QgSEFWRV9B
UkNIX0JJVFJFVkVSU0UNCj4gPiA+ID4gPiAtICAgc2VsZWN0IEhBVkVfQVJDSF9IVUdFX1ZNQVAN
Cj4gPiA+ID4gPiAgICAgICAgIHNlbGVjdCBIQVZFX0FSQ0hfSlVNUF9MQUJFTA0KPiA+ID4gPiA+
ICAgICAgICAgc2VsZWN0IEhBVkVfQVJDSF9LQVNBTiBpZiAhKEFSTTY0XzE2S19QQUdFUyAmJiBB
Uk02NF9WQV9CSVRTXzQ4KQ0KPiA+ID4gPiA+ICAgICAgICAgc2VsZWN0IEhBVkVfQVJDSF9LR0RC
DQo+ID4gPiA+IA0KPiA+ID4gPiBObywgdGhhdCBhY3R1YWxseSBicmVha3Mgd2l0aCB0aGUgdXNl
IG9mIGJsb2NrIG1hcHBpbmdzIGZvciB0aGUga2VybmVsDQo+ID4gPiA+IHRleHQuIEFueXdheSwg
c2VlOg0KPiA+ID4gPiANCj4gPiA+ID4gaHR0cHM6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xp
bnV4L2tlcm5lbC9naXQvdG9ydmFsZHMvbGludXguZ2l0L2NvbW1pdC8/aWQ9MTUxMjJlZTJjNTE1
YTI1M2IwYzY2YTNlNjE4YmM3ZWJlMzUxMDVlYg0KPiA+ID4gDQo+ID4gPiBTb3JyeSwganVzdCBi
YWNrIGZyb20gaG9saWRheXMgYW5kIGRpZG4ndCBjYXRjaCB1cCB3aXRoIGFsbCB0aGUgZW1haWxz
LA0KPiA+ID4gdGhhbmtzIGZvciB0YWtpbmcgY2FyZSBvZiB0aGlzLg0KPiA+IA0KPiA+IEkgd2ls
bCB3b3JrIG9uIGEgZml4IGZvciB0aGUgY29tbW9uL3g4NiBjb2RlLg0KPiANCj4gQWNlLCB0aGFu
a3MuIEknbSBtb3JlIHRoYW4gaGFwcHkgdG8gcmV2aWV3IGFueSBjaGFuZ2VzIHlvdSBtYWtlIHRv
IHRoZSBjb3JlDQo+IGNvZGUgZnJvbSBhIGJyZWFrLWJlZm9yZS1tYWtlIHBlcnNwZWN0aXZlLiBK
dXN0IHN0aWNrIG1lIG9uIGNjLg0KDQpUaGFua3MgV2lsbCEgIEkgd2lsbCBkZWZpbml0ZWx5IGtl
ZXAgeW91IGNjJ2QuDQotVG9zaGk=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

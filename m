Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 907726B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:22:17 -0400 (EDT)
Received: by obbhe7 with SMTP id he7so45635511obb.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:22:17 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id jq6si4227055obb.1.2015.08.20.16.22.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 16:22:16 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
Date: Thu, 20 Aug 2015 23:20:12 +0000
Message-ID: <20150820232011.GA10807@hori1.linux.bs1.fc.nec.co.jp>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820104929.GA4632@dhcp22.suse.cz>
In-Reply-To: <20150820104929.GA4632@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7C4EA0CCC30D54DA740D852E6FF5A6C@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

T24gVGh1LCBBdWcgMjAsIDIwMTUgYXQgMTI6NDk6MjlQTSArMDIwMCwgTWljaGFsIEhvY2tvIHdy
b3RlOg0KPiBPbiBUaHUgMjAtMDgtMTUgMDg6MjY6MjYsIE5hb3lhIEhvcmlndWNoaSB3cm90ZToN
Cj4gPiBDdXJyZW50bHkgL3Byb2MvUElEL3NtYXBzIHByb3ZpZGVzIG5vIHVzYWdlIGluZm8gZm9y
IHZtYShWTV9IVUdFVExCKSwgd2hpY2gNCj4gPiBpcyBpbmNvbnZlbmllbnQgd2hlbiB3ZSB3YW50
IHRvIGtub3cgcGVyLXRhc2sgb3IgcGVyLXZtYSBiYXNlIGh1Z2V0bGIgdXNhZ2UuDQo+ID4gVG8g
c29sdmUgdGhpcywgdGhpcyBwYXRjaCBhZGRzIGEgbmV3IGxpbmUgZm9yIGh1Z2V0bGIgdXNhZ2Ug
bGlrZSBiZWxvdzoNCj4gPiANCj4gPiAgIFNpemU6ICAgICAgICAgICAgICAyMDQ4MCBrQg0KPiA+
ICAgUnNzOiAgICAgICAgICAgICAgICAgICAwIGtCDQo+ID4gICBQc3M6ICAgICAgICAgICAgICAg
ICAgIDAga0INCj4gPiAgIFNoYXJlZF9DbGVhbjogICAgICAgICAgMCBrQg0KPiA+ICAgU2hhcmVk
X0RpcnR5OiAgICAgICAgICAwIGtCDQo+ID4gICBQcml2YXRlX0NsZWFuOiAgICAgICAgIDAga0IN
Cj4gPiAgIFByaXZhdGVfRGlydHk6ICAgICAgICAgMCBrQg0KPiA+ICAgUmVmZXJlbmNlZDogICAg
ICAgICAgICAwIGtCDQo+ID4gICBBbm9ueW1vdXM6ICAgICAgICAgICAgIDAga0INCj4gPiAgIEFu
b25IdWdlUGFnZXM6ICAgICAgICAgMCBrQg0KPiA+ICAgSHVnZXRsYlBhZ2VzOiAgICAgIDE4NDMy
IGtCDQo+ID4gICBTd2FwOiAgICAgICAgICAgICAgICAgIDAga0INCj4gPiAgIEtlcm5lbFBhZ2VT
aXplOiAgICAgMjA0OCBrQg0KPiA+ICAgTU1VUGFnZVNpemU6ICAgICAgICAyMDQ4IGtCDQo+ID4g
ICBMb2NrZWQ6ICAgICAgICAgICAgICAgIDAga0INCj4gPiAgIFZtRmxhZ3M6IHJkIHdyIG1yIG13
IG1lIGRlIGh0DQo+IA0KPiBJIGhhdmUgb25seSBub3cgZ290IHRvIHRoaXMgdGhyZWFkLiBUaGlz
IGlzIGluZGVlZCB2ZXJ5IGhlbHBmdWwuIEkgd291bGQNCj4ganVzdCBzdWdnZXN0IHRvIHVwZGF0
ZSBEb2N1bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3Byb2MudHh0IHRvIGJlIGV4cGxpY2l0DQo+IHRo
YXQgUnNzOiBkb2Vzbid0IGNvdW50IGh1Z2V0bGIgcGFnZXMgZm9yIGhpc3RvcmljYWwgcmVhc29u
cy4NCg0KSSBhZ3JlZSwgSSB3YW50IHRoZSBmb2xsb3dpbmcgZGlmZiB0byBiZSBmb2xkZWQgdG8g
dGhpcyBwYXRjaC4NCg0KPiAgDQo+ID4gU2lnbmVkLW9mZi1ieTogTmFveWEgSG9yaWd1Y2hpIDxu
LWhvcmlndWNoaUBhaC5qcC5uZWMuY29tPg0KPiA+IEFja2VkLWJ5OiBKb2VybiBFbmdlbCA8am9l
cm5AbG9nZnMub3JnPg0KPiA+IEFja2VkLWJ5OiBEYXZpZCBSaWVudGplcyA8cmllbnRqZXNAZ29v
Z2xlLmNvbT4NCj4gDQo+IEFja2VkLWJ5OiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmN6Pg0K
DQpUaGFuayB5b3UuDQpOYW95YSBIb3JpZ3VjaGkNCi0tLQ0KRnJvbTogTmFveWEgSG9yaWd1Y2hp
IDxuLWhvcmlndWNoaUBhaC5qcC5uZWMuY29tPg0KRGF0ZTogRnJpLCAyMSBBdWcgMjAxNSAwODox
MzozMSArMDkwMA0KU3ViamVjdDogW1BBVENIXSBEb2N1bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3By
b2MudHh0OiBnaXZlIGFkZGl0aW9uYWwgY29tbWVudA0KIGFib3V0IGh1Z2V0bGIgdXNhZ2UNCg0K
LS0tDQogRG9jdW1lbnRhdGlvbi9maWxlc3lzdGVtcy9wcm9jLnR4dCB8IDMgKystDQogMSBmaWxl
IGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQ0KDQpkaWZmIC0tZ2l0IGEv
RG9jdW1lbnRhdGlvbi9maWxlc3lzdGVtcy9wcm9jLnR4dCBiL0RvY3VtZW50YXRpb24vZmlsZXN5
c3RlbXMvcHJvYy50eHQNCmluZGV4IGY1NjFmYzQ2ZTQxYi4uYjc3NWI2ZmFhZWRhIDEwMDY0NA0K
LS0tIGEvRG9jdW1lbnRhdGlvbi9maWxlc3lzdGVtcy9wcm9jLnR4dA0KKysrIGIvRG9jdW1lbnRh
dGlvbi9maWxlc3lzdGVtcy9wcm9jLnR4dA0KQEAgLTQ0Niw3ICs0NDYsOCBAQCBpbmRpY2F0ZXMg
dGhlIGFtb3VudCBvZiBtZW1vcnkgY3VycmVudGx5IG1hcmtlZCBhcyByZWZlcmVuY2VkIG9yIGFj
Y2Vzc2VkLg0KIGEgbWFwcGluZyBhc3NvY2lhdGVkIHdpdGggYSBmaWxlIG1heSBjb250YWluIGFu
b255bW91cyBwYWdlczogd2hlbiBNQVBfUFJJVkFURQ0KIGFuZCBhIHBhZ2UgaXMgbW9kaWZpZWQs
IHRoZSBmaWxlIHBhZ2UgaXMgcmVwbGFjZWQgYnkgYSBwcml2YXRlIGFub255bW91cyBjb3B5Lg0K
ICJBbm9uSHVnZVBhZ2VzIiBzaG93cyB0aGUgYW1tb3VudCBvZiBtZW1vcnkgYmFja2VkIGJ5IHRy
YW5zcGFyZW50IGh1Z2VwYWdlLg0KLSJIdWdldGxiUGFnZXMiIHNob3dzIHRoZSBhbW1vdW50IG9m
IG1lbW9yeSBiYWNrZWQgYnkgaHVnZXRsYmZzIHBhZ2UuDQorIkh1Z2V0bGJQYWdlcyIgc2hvd3Mg
dGhlIGFtbW91bnQgb2YgbWVtb3J5IGJhY2tlZCBieSBodWdldGxiZnMgcGFnZSAod2hpY2ggaXMN
Citub3QgY291bnRlZCBpbiAiUnNzIiBvciAiUHNzIiBmaWVsZCBmb3IgaGlzdG9yaWNhbCByZWFz
b25zLikNCiAiU3dhcCIgc2hvd3MgaG93IG11Y2ggd291bGQtYmUtYW5vbnltb3VzIG1lbW9yeSBp
cyBhbHNvIHVzZWQsIGJ1dCBvdXQgb24gc3dhcC4NCiANCiAiVm1GbGFncyIgZmllbGQgZGVzZXJ2
ZXMgYSBzZXBhcmF0ZSBkZXNjcmlwdGlvbi4gVGhpcyBtZW1iZXIgcmVwcmVzZW50cyB0aGUga2Vy
bmVsDQotLSANCjIuNC4zDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

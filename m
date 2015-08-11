Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 824596B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 19:48:04 -0400 (EDT)
Received: by pawu10 with SMTP id u10so892601paw.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 16:48:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id hy9si6280378pac.82.2015.08.11.16.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 16:48:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t7BNm0UR022901
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 08:48:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] smaps: fill missing fields for vma(VM_HUGETLB)
Date: Tue, 11 Aug 2015 23:32:38 +0000
Message-ID: <20150811233237.GA32192@hori1.linux.bs1.fc.nec.co.jp>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
 <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1508101727230.28691@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1508101727230.28691@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <CB0BC8457ACF8845A740CD1AE71FD493@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

T24gTW9uLCBBdWcgMTAsIDIwMTUgYXQgMDU6Mzc6NTRQTSAtMDcwMCwgRGF2aWQgUmllbnRqZXMg
d3JvdGU6DQo+IE9uIEZyaSwgNyBBdWcgMjAxNSwgTmFveWEgSG9yaWd1Y2hpIHdyb3RlOg0KPiAN
Cj4gPiBDdXJyZW50bHkgc21hcHMgcmVwb3J0cyBtYW55IHplcm8gZmllbGRzIGZvciB2bWEoVk1f
SFVHRVRMQiksIHdoaWNoIGlzDQo+ID4gaW5jb252ZW5pZW50IHdoZW4gd2Ugd2FudCB0byBrbm93
IHBlci10YXNrIG9yIHBlci12bWEgYmFzZSBodWdldGxiIHVzYWdlLg0KPiA+IFRoaXMgcGF0Y2gg
ZW5hYmxlcyB0aGVzZSBmaWVsZHMgYnkgaW50cm9kdWNpbmcgc21hcHNfaHVnZXRsYl9yYW5nZSgp
Lg0KPiA+IA0KPiA+IGJlZm9yZSBwYXRjaDoNCj4gPiANCj4gPiAgIFNpemU6ICAgICAgICAgICAg
ICAyMDQ4MCBrQg0KPiA+ICAgUnNzOiAgICAgICAgICAgICAgICAgICAwIGtCDQo+ID4gICBQc3M6
ICAgICAgICAgICAgICAgICAgIDAga0INCj4gPiAgIFNoYXJlZF9DbGVhbjogICAgICAgICAgMCBr
Qg0KPiA+ICAgU2hhcmVkX0RpcnR5OiAgICAgICAgICAwIGtCDQo+ID4gICBQcml2YXRlX0NsZWFu
OiAgICAgICAgIDAga0INCj4gPiAgIFByaXZhdGVfRGlydHk6ICAgICAgICAgMCBrQg0KPiA+ICAg
UmVmZXJlbmNlZDogICAgICAgICAgICAwIGtCDQo+ID4gICBBbm9ueW1vdXM6ICAgICAgICAgICAg
IDAga0INCj4gPiAgIEFub25IdWdlUGFnZXM6ICAgICAgICAgMCBrQg0KPiA+ICAgU3dhcDogICAg
ICAgICAgICAgICAgICAwIGtCDQo+ID4gICBLZXJuZWxQYWdlU2l6ZTogICAgIDIwNDgga0INCj4g
PiAgIE1NVVBhZ2VTaXplOiAgICAgICAgMjA0OCBrQg0KPiA+ICAgTG9ja2VkOiAgICAgICAgICAg
ICAgICAwIGtCDQo+ID4gICBWbUZsYWdzOiByZCB3ciBtciBtdyBtZSBkZSBodA0KPiA+IA0KPiA+
IGFmdGVyIHBhdGNoOg0KPiA+IA0KPiA+ICAgU2l6ZTogICAgICAgICAgICAgIDIwNDgwIGtCDQo+
ID4gICBSc3M6ICAgICAgICAgICAgICAgMTg0MzIga0INCj4gPiAgIFBzczogICAgICAgICAgICAg
ICAxODQzMiBrQg0KPiA+ICAgU2hhcmVkX0NsZWFuOiAgICAgICAgICAwIGtCDQo+ID4gICBTaGFy
ZWRfRGlydHk6ICAgICAgICAgIDAga0INCj4gPiAgIFByaXZhdGVfQ2xlYW46ICAgICAgICAgMCBr
Qg0KPiA+ICAgUHJpdmF0ZV9EaXJ0eTogICAgIDE4NDMyIGtCDQo+ID4gICBSZWZlcmVuY2VkOiAg
ICAgICAgMTg0MzIga0INCj4gPiAgIEFub255bW91czogICAgICAgICAxODQzMiBrQg0KPiA+ICAg
QW5vbkh1Z2VQYWdlczogICAgICAgICAwIGtCDQo+ID4gICBTd2FwOiAgICAgICAgICAgICAgICAg
IDAga0INCj4gPiAgIEtlcm5lbFBhZ2VTaXplOiAgICAgMjA0OCBrQg0KPiA+ICAgTU1VUGFnZVNp
emU6ICAgICAgICAyMDQ4IGtCDQo+ID4gICBMb2NrZWQ6ICAgICAgICAgICAgICAgIDAga0INCj4g
PiAgIFZtRmxhZ3M6IHJkIHdyIG1yIG13IG1lIGRlIGh0DQo+ID4gDQo+IA0KPiBJIHRoaW5rIHRo
aXMgd2lsbCBsZWFkIHRvIGJyZWFrYWdlLCB1bmZvcnR1bmF0ZWx5LCBzcGVjaWZpY2FsbHkgZm9y
IHVzZXJzIA0KPiB3aG8gYXJlIGNvbmNlcm5lZCB3aXRoIHJlc291cmNlIG1hbmFnZW1lbnQuDQo+
IA0KPiBBbiBleGFtcGxlOiB3ZSB1c2UgbWVtY2cgaGllcmFyY2hpZXMgdG8gY2hhcmdlIG1lbW9y
eSBmb3IgaW5kaXZpZHVhbCBqb2JzLCANCj4gc3BlY2lmaWMgdXNlcnMsIGFuZCBzeXN0ZW0gb3Zl
cmhlYWQuICBNZW1jZyBpcyBhIGNncm91cCwgc28gdGhpcyBpcyBkb25lIA0KPiBmb3IgYW4gYWdn
cmVnYXRlIG9mIHByb2Nlc3NlcywgYW5kIHdlIG9mdGVuIGhhdmUgdG8gbW9uaXRvciB0aGVpciBt
ZW1vcnkgDQo+IHVzYWdlLiAgRWFjaCBwcm9jZXNzIGlzbid0IGFzc2lnbmVkIHRvIGl0cyBvd24g
bWVtY2csIGFuZCBJIGRvbid0IGJlbGlldmUgDQo+IGNvbW1vbiB1c2VycyBvZiBtZW1jZyBhc3Np
Z24gaW5kaXZpZHVhbCBwcm9jZXNzZXMgdG8gdGhlaXIgb3duIG1lbWNncy4gIA0KPiANCj4gV2hl
biBhIG1lbWNnIGlzIG91dCBvZiBtZW1vcnksIHdlIG5lZWQgdG8gdHJhY2sgdGhlIG1lbW9yeSB1
c2FnZSBvZiANCj4gcHJvY2Vzc2VzIGF0dGFjaGVkIHRvIGl0cyBtZW1jZyBoaWVyYXJjaHkgdG8g
ZGV0ZXJtaW5lIHdoYXQgaXMgdW5leHBlY3RlZCwgDQo+IGVpdGhlciBhcyBhIHJlc3VsdCBvZiBh
IG5ldyByb2xsb3V0IG9yIGJlY2F1c2Ugb2YgYSBtZW1vcnkgbGVhay4gIFRvIGRvIA0KPiB0aGF0
LCB3ZSB1c2UgdGhlIHJzcyBleHBvcnRlZCBieSBzbWFwcyB0aGF0IGlzIG5vdyBjaGFuZ2VkIHdp
dGggdGhpcyANCj4gcGF0Y2guICBCeSB1c2luZyBzbWFwcyByYXRoZXIgdGhhbiAvcHJvYy9waWQv
c3RhdHVzLCB3ZSBjYW4gcmVwb3J0IHdoZXJlIA0KPiBtZW1vcnkgdXNhZ2UgaXMgdW5leHBlY3Rl
ZC4NCj4gDQo+IFRoaXMgd291bGQgY2F1c2Ugb3VyIHByb2Nlc3MgdGhhdCBtYW5hZ2VzIGFsbCBt
ZW1jZ3Mgb24gb3VyIHN5c3RlbXMgdG8gDQo+IGJyZWFrLiAgUGVyaGFwcyBJIGhhdmVuJ3QgYmVl
biBhcyBjb252aW5jaW5nIGluIG15IHByZXZpb3VzIG1lc3NhZ2VzIG9mIA0KPiB0aGlzLCBidXQg
aXQncyBxdWl0ZSBhbiBvYnZpb3VzIHVzZXJzcGFjZSByZWdyZXNzaW9uLg0KDQpPSywgdGhpcyB2
ZXJzaW9uIGFzc3VtZXMgdGhhdCB1c2Vyc3BhY2UgZGlzdGluZ3Vpc2hlcyB2bWEoVk1fSFVHRVRM
Qikgd2l0aA0KIlZtRmxhZ3MiIGZpZWxkLCB3aGljaCBpcyB1bnJlYWxpc3RpYy4gU28gSSdsbCBr
ZWVwIGFsbCBleGlzdGluZyBmaWVsZHMNCnVudG91Y2hlZCBieSBpbnRyb2R1Y2luZyBodWdldGxi
IHVzYWdlIGluZm8uDQoNCj4gVGhpcyBtZW1vcnkgd2FzIG5vdCBpbmNsdWRlZCBpbiByc3Mgb3Jp
Z2luYWxseSBiZWNhdXNlIG1lbW9yeSBpbiB0aGUgDQo+IGh1Z2V0bGIgcGVyc2lzdGVudCBwb29s
IGlzIGFsd2F5cyByZXNpZGVudC4gIFVubWFwcGluZyB0aGUgbWVtb3J5IGRvZXMgbm90IA0KPiBm
cmVlIG1lbW9yeS4gIEZvciB0aGlzIHJlYXNvbiwgaHVnZXRsYiBtZW1vcnkgaGFzIGFsd2F5cyBi
ZWVuIHRyZWF0ZWQgYXMgDQo+IGl0cyBvd24gdHlwZSBvZiBtZW1vcnkuDQoNClJpZ2h0LCBzbyBp
dCBtaWdodCBiZSBiZXR0ZXIgbm90IHRvIHVzZSB0aGUgd29yZCAiUlNTIiBmb3IgaHVnZXRsYiwg
bWF5YmUNCnNvbWV0aGluZyBsaWtlICJIdWdldGxiUGFnZXM6IiBzZWVtcyBiZXR0ZXIgdG8gbWUu
DQoNClRoYW5rcywNCk5hb3lhIEhvcmlndWNoaQ0KDQo+IEl0IHdvdWxkIGhhdmUgYmVlbiBhcmd1
YWJsZSBiYWNrIHdoZW4gaHVnZXRsYmZzIHdhcyBpbnRyb2R1Y2VkIHdoZXRoZXIgaXQgDQo+IHNo
b3VsZCBiZSBpbmNsdWRlZC4gIEknbSBhZnJhaWQgdGhlIHNoaXAgaGFzIHNhaWxlZCBvbiB0aGF0
IHNpbmNlIGEgZGVjYWRlIA0KPiBoYXMgcGFzdCBhbmQgaXQgd291bGQgY2F1c2UgdXNlcnNwYWNl
IHRvIGJyZWFrIGlmIGV4aXN0aW5nIG1ldHJpY3MgYXJlIA0KPiB1c2VkIHRoYXQgYWxyZWFkeSBo
YXZlIGNsZWFyZWQgZGVmaW5lZCBzZW1hbnRpY3Mu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

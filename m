Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18FA88E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:32:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x19-v6so11311315pfh.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:32:20 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0098.outbound.protection.outlook.com. [104.47.40.98])
        by mx.google.com with ESMTPS id y26-v6si16127140pfe.269.2018.09.10.07.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Sep 2018 07:32:18 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Date: Mon, 10 Sep 2018 14:32:16 +0000
Message-ID: 
 <CAGM2reZ5OD9SRW8j9iaQAk9jpr86pF2NqpBjv-dxH+1vJZs0=g@mail.gmail.com>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
 <20180910135959.GI10951@dhcp22.suse.cz>
 <CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
 <20180910141946.GJ10951@dhcp22.suse.cz>
In-Reply-To: <20180910141946.GJ10951@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4B5AC2E24D7AED4EA6437DE74B7EC4FC@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "zaslonko@linux.ibm.com" <zaslonko@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

T24gTW9uLCBTZXAgMTAsIDIwMTggYXQgMTA6MTkgQU0gTWljaGFsIEhvY2tvIDxtaG9ja29Aa2Vy
bmVsLm9yZz4gd3JvdGU6DQo+DQo+IE9uIE1vbiAxMC0wOS0xOCAxNDoxMTo0NSwgUGF2ZWwgVGF0
YXNoaW4gd3JvdGU6DQo+ID4gSGkgTWljaGFsLA0KPiA+DQo+ID4gSXQgaXMgdHJpY2t5LCBidXQg
cHJvYmFibHkgY2FuIGJlIGRvbmUuIEVpdGhlciBjaGFuZ2UNCj4gPiBtZW1tYXBfaW5pdF96b25l
KCkgb3IgaXRzIGNhbGxlciB0byBhbHNvIGNvdmVyIHRoZSBlbmRzIGFuZCBzdGFydHMgb2YNCj4g
PiB1bmFsaWduZWQgc2VjdGlvbnMgdG8gaW5pdGlhbGl6ZSBhbmQgcmVzZXJ2ZSBwYWdlcy4NCj4g
Pg0KPiA+IFRoZSBzYW1lIHRoaW5nIHdvdWxkIGFsc28gbmVlZCB0byBiZSBkb25lIGluIGRlZmVy
cmVkX2luaXRfbWVtbWFwKCkgdG8NCj4gPiBjb3ZlciB0aGUgZGVmZXJyZWQgaW5pdCBjYXNlLg0K
Pg0KPiBXZWxsLCBJIGFtIG5vdCBzdXJlIFRCSC4gSSBoYXZlIHRvIHRoaW5rIGFib3V0IHRoYXQg
bXVjaCBtb3JlLiBNYXliZSBpdA0KPiB3b3VsZCBiZSBtdWNoIG1vcmUgc2ltcGxlIHRvIG1ha2Ug
c3VyZSB0aGF0IHdlIHdpbGwgbmV2ZXIgYWRkIGluY29tcGxldGUNCj4gbWVtYmxvY2tzIGFuZCBz
aW1wbHkgcmVmdXNlIHRoZW0gZHVyaW5nIHRoZSBkaXNjb3ZlcnkuIEF0IGxlYXN0IGZvciBub3cu
DQoNCk9uIHg4NiBtZW1ibG9ja3MgY2FuIGJlIHVwdG8gMkcgb24gbWFjaGluZXMgd2l0aCBvdmVy
IDY0RyBvZiBSQU0uDQpBbHNvLCBtZW1vcnkgc2l6ZSBpcyB3YXkgdG8gZWFzeSB0b28gY2hhbmdl
IHZpYSBxZW11IGFyZ3VtZW50cyB3aGVuIFZNDQpzdGFydHMuIElmIHdlIHNpbXBseSBkaXNhYmxl
IHVuYWxpZ25lZCB0cmFpbGluZyBtZW1ibG9ja3MsIEkgYW0gc3VyZQ0Kd2Ugd291bGQgZ2V0IHRv
bnMgb2Ygbm9pc2Ugb2YgbWlzc2luZyBtZW1vcnkuDQoNCkkgdGhpbmssIGFkZGluZyBjaGVja19o
b3RwbHVnX21lbW9yeV9yYW5nZSgpIHdvdWxkIHdvcmsgdG8gZml4IHRoZQ0KaW1tZWRpYXRlIHBy
b2JsZW0uIEJ1dCwgd2UgZG8gbmVlZCB0byBmaWd1cmUgb3V0ICBhIGJldHRlciBzb2x1dGlvbi4N
Cg0KbWVtYmxvY2sgZGVzaWduIGlzIGJhc2VkIG9uIGFyY2hhaWMgYXNzdW1wdGlvbiB0aGF0IGhv
dHBsdWcgdW5pdHMgYXJlDQpwaHlzaWNhbCBkaW1tcy4gVk1zIGFuZCBoeXBlcnZpc29ycyBjaGFu
Z2VkIGFsbCBvZiB0aGF0LCBhbmQgd2UgY2FuDQpoYXZlIG11Y2ggZmluZXIgaG90cGx1ZyByZXF1
ZXN0cyBvbiBtYWNoaW5lcyB3aXRoIGh1Z2UgRElNTXMuIFlldCwgd2UNCmRvIG5vdCB3YW50IHRv
IHBvbGx1dGUgc3lzZnMgd2l0aCBtaWxsaW9ucyBvZiB0aW55IG1lbW9yeSBkZXZpY2VzLiBJDQph
bSBub3Qgc3VyZSB3aGF0IGEgbG9uZyB0ZXJtIHByb3BlciBzb2x1dGlvbiBmb3IgdGhpcyBwcm9i
bGVtIHNob3VsZA0KYmUsIGJ1dCBJIHNlZSB0aGF0IGxpbnV4IGhvdHBsdWcvaG90cmVtb3ZlIHN1
YnN5c3RlbXMgbXVzdCBiZQ0KcmVkZXNpZ25lZCBiYXNlZCBvbiB0aGUgbmV3IHJlcXVpcmVtZW50
cy4NCg0KUGF2ZWw=

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52BA96B42FB
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 19:18:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x204-v6so683096qka.6
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:18:45 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0125.outbound.protection.outlook.com. [104.47.38.125])
        by mx.google.com with ESMTPS id c18-v6si570578qvq.4.2018.08.27.16.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Aug 2018 16:18:44 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 1/2] Revert "x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved"
Date: Mon, 27 Aug 2018 23:18:42 +0000
Message-ID: <f3f1b835-8762-5644-a9aa-fac11ba07b14@microsoft.com>
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
In-Reply-To: <20180823182513.8801-1-msys.mizuma@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C7E6988B164F9E46B69C06C89B833C19@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

T24gOC8yMy8xOCAyOjI1IFBNLCBNYXNheW9zaGkgTWl6dW1hIHdyb3RlOg0KPiBGcm9tOiBNYXNh
eW9zaGkgTWl6dW1hIDxtLm1penVtYUBqcC5mdWppdHN1LmNvbT4NCj4gDQo+IGNvbW1pdCAxMjQw
NDlkZWNiYjEgKCJ4ODYvZTgyMDogcHV0ICFFODIwX1RZUEVfUkFNIHJlZ2lvbnMgaW50bw0KPiBt
ZW1ibG9jay5yZXNlcnZlZCIpIGJyZWFrcyBtb3ZhYmxlX25vZGUga2VybmVsIG9wdGlvbiBiZWNh
dXNlIGl0DQo+IGNoYW5nZWQgdGhlIG1lbW9yeSBnYXAgcmFuZ2UgdG8gcmVzZXJ2ZWQgbWVtYmxv
Y2suIFNvLCB0aGUgbm9kZQ0KPiBpcyBtYXJrZWQgYXMgTm9ybWFsIHpvbmUgZXZlbiBpZiB0aGUg
U1JBVCBoYXMgSG90IHBsYWdnYWJsZSBhZmZpbml0eS4NCj4gDQo+ICAgICA9PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0N
Cj4gICAgIGtlcm5lbDogQklPUy1lODIwOiBbbWVtIDB4MDAwMDE4MDAwMDAwMDAwMC0weDAwMDAx
ODBmZmZmZmZmZmZdIHVzYWJsZQ0KPiAgICAga2VybmVsOiBCSU9TLWU4MjA6IFttZW0gMHgwMDAw
MWMwMDAwMDAwMDAwLTB4MDAwMDFjMGZmZmZmZmZmZl0gdXNhYmxlDQo+ICAgICAuLi4NCj4gICAg
IGtlcm5lbDogcmVzZXJ2ZWRbMHgxMl0jMDExWzB4MDAwMDE4MTAwMDAwMDAwMC0weDAwMDAxYmZm
ZmZmZmZmZmZdLCAweDAwMDAwM2YwMDAwMDAwMDAgYnl0ZXMgZmxhZ3M6IDB4MA0KPiAgICAgLi4u
DQo+ICAgICBrZXJuZWw6IEFDUEk6IFNSQVQ6IE5vZGUgMiBQWE0gNiBbbWVtIDB4MTgwMDAwMDAw
MDAwLTB4MWJmZmZmZmZmZmZmXSBob3RwbHVnDQo+ICAgICBrZXJuZWw6IEFDUEk6IFNSQVQ6IE5v
ZGUgMyBQWE0gNyBbbWVtIDB4MWMwMDAwMDAwMDAwLTB4MWZmZmZmZmZmZmZmXSBob3RwbHVnDQo+
ICAgICAuLi4NCj4gICAgIGtlcm5lbDogTW92YWJsZSB6b25lIHN0YXJ0IGZvciBlYWNoIG5vZGUN
Cj4gICAgIGtlcm5lbDogIE5vZGUgMzogMHgwMDAwMWMwMDAwMDAwMDAwDQo+ICAgICBrZXJuZWw6
IEVhcmx5IG1lbW9yeSBub2RlIHJhbmdlcw0KPiAgICAgLi4uDQo+ICAgICA9PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0N
Cj4gDQo+IE5hb3lhJ3MgdjEgcGF0Y2ggWypdIGZpeGVzIHRoZSBvcmlnaW5hbCBpc3N1ZSBhbmQg
dGhpcyBtb3ZhYmxlX25vZGUNCj4gaXNzdWUgZG9lc24ndCBvY2N1ci4NCj4gTGV0J3MgcmV2ZXJ0
IGNvbW1pdCAxMjQwNDlkZWNiYjEgKCJ4ODYvZTgyMDogcHV0ICFFODIwX1RZUEVfUkFNDQo+IHJl
Z2lvbnMgaW50byBtZW1ibG9jay5yZXNlcnZlZCIpIGFuZCBhcHBseSB0aGUgdjEgcGF0Y2guDQo+
IA0KPiBbKl0gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTgvNi8xMy8yNw0KPiANCj4gU2lnbmVk
LW9mZi1ieTogTWFzYXlvc2hpIE1penVtYSA8bS5taXp1bWFAanAuZnVqaXRzdS5jb20+DQoNClJl
dmlld2VkLWJ5OiBQYXZlbCBUYXRhc2hpbiA8cGF2ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNvbT4=

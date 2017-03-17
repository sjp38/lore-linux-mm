Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF96C6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 18:58:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e188so7132749oif.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 15:58:24 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0125.outbound.protection.outlook.com. [104.47.34.125])
        by mx.google.com with ESMTPS id k74si3962736oib.69.2017.03.17.15.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 15:58:24 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [RFC PATCH v4 15/28] Add support to access persistent memory in
 the clear
Date: Fri, 17 Mar 2017 22:58:21 +0000
Message-ID: <DF4PR84MB01694A716568EFB01F5C1C5EAB390@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154521.19244.89502.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154521.19244.89502.stgit@tlendack-t1.amdoffice.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg
 Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbGludXgta2VybmVsLW93
bmVyQHZnZXIua2VybmVsLm9yZyBbbWFpbHRvOmxpbnV4LWtlcm5lbC0NCj4gb3duZXJAdmdlci5r
ZXJuZWwub3JnXSBPbiBCZWhhbGYgT2YgVG9tIExlbmRhY2t5DQo+IFNlbnQ6IFRodXJzZGF5LCBG
ZWJydWFyeSAxNiwgMjAxNyA5OjQ1IEFNDQo+IFN1YmplY3Q6IFtSRkMgUEFUQ0ggdjQgMTUvMjhd
IEFkZCBzdXBwb3J0IHRvIGFjY2VzcyBwZXJzaXN0ZW50IG1lbW9yeSBpbg0KPiB0aGUgY2xlYXIN
Cj4gDQo+IFBlcnNpc3RlbnQgbWVtb3J5IGlzIGV4cGVjdGVkIHRvIHBlcnNpc3QgYWNyb3NzIHJl
Ym9vdHMuIFRoZSBlbmNyeXB0aW9uDQo+IGtleSB1c2VkIGJ5IFNNRSB3aWxsIGNoYW5nZSBhY3Jv
c3MgcmVib290cyB3aGljaCB3aWxsIHJlc3VsdCBpbiBjb3JydXB0ZWQNCj4gcGVyc2lzdGVudCBt
ZW1vcnkuICBQZXJzaXN0ZW50IG1lbW9yeSBpcyBoYW5kZWQgb3V0IGJ5IGJsb2NrIGRldmljZXMN
Cj4gdGhyb3VnaCBtZW1vcnkgcmVtYXBwaW5nIGZ1bmN0aW9ucywgc28gYmUgc3VyZSBub3QgdG8g
bWFwIHRoaXMgbWVtb3J5IGFzDQo+IGVuY3J5cHRlZC4NCg0KVGhlIHN5c3RlbSBtaWdodCBiZSBh
YmxlIHRvIHNhdmUgYW5kIHJlc3RvcmUgdGhlIGNvcnJlY3QgZW5jcnlwdGlvbiBrZXkgZm9yIGEg
DQpyZWdpb24gb2YgcGVyc2lzdGVudCBtZW1vcnksIGluIHdoaWNoIGNhc2UgaXQgZG9lcyBuZWVk
IHRvIGJlIG1hcHBlZCBhcw0KZW5jcnlwdGVkLg0KDQpUaGlzIG1pZ2h0IGRlc2VydmUgYSBuZXcg
RUZJX01FTU9SWV9FTkNSWVBURUQgYXR0cmlidXRlIGJpdCBzbyB0aGUNCnN5c3RlbSBmaXJtd2Fy
ZSBjYW4gY29tbXVuaWNhdGUgdGhhdCBpbmZvcm1hdGlvbiB0byB0aGUgT1MgKGluIHRoZQ0KVUVG
SSBtZW1vcnkgbWFwIGFuZCB0aGUgQUNQSSBORklUIFNQQSBSYW5nZSBzdHJ1Y3R1cmVzKS4gIEl0
IHdvdWxkbid0DQpsaWtlbHkgZXZlciBiZSBhZGRlZCB0byB0aGUgRTgyMGggdGFibGUgLSBBQ1BJ
IDYuMSBhbHJlYWR5IG9ic29sZXRlZCB0aGUNCkV4dGVuZGVkIEF0dHJpYnV0ZSBmb3IgQWRkcmVz
c1JhbmdlTm9uVm9sYXRpbGUuDQoNCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFRvbSBMZW5kYWNreSA8
dGhvbWFzLmxlbmRhY2t5QGFtZC5jb20+DQo+IC0tLQ0KPiAgYXJjaC94ODYvbW0vaW9yZW1hcC5j
IHwgICAgMiArKw0KPiAgMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlm
ZiAtLWdpdCBhL2FyY2gveDg2L21tL2lvcmVtYXAuYyBiL2FyY2gveDg2L21tL2lvcmVtYXAuYw0K
PiBpbmRleCBiMGZmNmJjLi5jNmNiOTIxIDEwMDY0NA0KPiAtLS0gYS9hcmNoL3g4Ni9tbS9pb3Jl
bWFwLmMNCj4gKysrIGIvYXJjaC94ODYvbW0vaW9yZW1hcC5jDQo+IEBAIC00OTgsNiArNDk4LDgg
QEAgc3RhdGljIGJvb2wNCj4gbWVtcmVtYXBfc2hvdWxkX21hcF9lbmNyeXB0ZWQocmVzb3VyY2Vf
c2l6ZV90IHBoeXNfYWRkciwNCj4gIAljYXNlIEU4MjBfVFlQRV9BQ1BJOg0KPiAgCWNhc2UgRTgy
MF9UWVBFX05WUzoNCj4gIAljYXNlIEU4MjBfVFlQRV9VTlVTQUJMRToNCj4gKwljYXNlIEU4MjBf
VFlQRV9QTUVNOg0KPiArCWNhc2UgRTgyMF9UWVBFX1BSQU06DQo+ICAJCXJldHVybiBmYWxzZTsN
Cj4gIAlkZWZhdWx0Og0KPiAgCQlicmVhazsNCg0KRTgyMF9UWVBFX1JFU0VSVkVEIGlzIGFsc28g
dXNlZCB0byByZXBvcnQgcGVyc2lzdGVudCBtZW1vcnkgaW4NCnNvbWUgc3lzdGVtcyAocGF0Y2gg
MTYgYWRkcyB0aGF0IGZvciBvdGhlciByZWFzb25zKS4NCg0KWW91IG1pZ2h0IHdhbnQgdG8gaW50
ZXJjZXB0IHRoZSBwZXJzaXN0ZW50IG1lbW9yeSB0eXBlcyBpbiB0aGUgDQplZmlfbWVtX3R5cGUo
cGh5c19hZGRyKSBzd2l0Y2ggc3RhdGVtZW50IGVhcmxpZXIgaW4gdGhlIGZ1bmN0aW9uDQphcyB3
ZWxsLiAgaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTcvMy8xMy8zNTcgcmVjZW50bHkgbWVudGlv
bmVkIHRoYXQNCiJpbiBxZW11IGhvdHBsdWdnYWJsZSBtZW1vcnkgaXNuJ3QgcHV0IGludG8gRTgy
MCwiIHdpdGggdGhlIGxhdGVzdCANCmluZm9ybWF0aW9uIG9ubHkgaW4gdGhlIFVFRkkgbWVtb3J5
IG1hcC4NCg0KUGVyc2lzdGVudCBtZW1vcnkgY2FuIGJlIHJlcG9ydGVkIHRoZXJlIGFzOg0KKiBF
ZmlSZXNlcnZlZE1lbW9yeVR5cGUgdHlwZSB3aXRoIHRoZSBFRklfTUVNT1JZX05WIGF0dHJpYnV0
ZQ0KKiBFZmlQZXJzaXN0ZW50TWVtb3J5IHR5cGUgd2l0aCB0aGUgRUZJX01FTU9SWV9OViBhdHRy
aWJ1dGUNCg0KRXZlbiB0aGUgVUVGSSBtZW1vcnkgbWFwIGlzIG5vdCBhdXRob3JpdGF0aXZlLCB0
aG91Z2guICBUbyByZWFsbHkNCmRldGVybWluZSB3aGF0IGlzIGluIHRoZXNlIHJlZ2lvbnMgcmVx
dWlyZXMgcGFyc2luZyB0aGUgQUNQSSBORklUDQpTUEEgUmFuZ2VzIHN0cnVjdHVyZXMuICBQYXJ0
cyBvZiB0aGUgRTgyMCBvciBVRUZJIHJlZ2lvbnMgY291bGQgYmUNCnJlcG9ydGVkIGFzIHZvbGF0
aWxlIHRoZXJlIGFuZCBzaG91bGQgdGh1cyBiZSBlbmNyeXB0ZWQuDQoNCi0tLQ0KUm9iZXJ0IEVs
bGlvdHQsIEhQRSBQZXJzaXN0ZW50IE1lbW9yeQ0KDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

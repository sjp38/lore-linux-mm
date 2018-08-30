Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E053A6B52FE
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:37:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s1-v6so9885639qte.19
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:37:39 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700122.outbound.protection.outlook.com. [40.107.70.122])
        by mx.google.com with ESMTPS id 30-v6si1698958qtv.79.2018.08.30.12.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 12:37:39 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 3/6] mm/memory_hotplug: fix online/offline_pages
 called w.o. mem_hotplug_lock
Date: Thu, 30 Aug 2018 19:37:34 +0000
Message-ID: <a34ab7ac-e33b-47aa-0ee2-94d83de8c367@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-4-david@redhat.com>
In-Reply-To: <20180821104418.12710-4-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3469F0C8B8592041A0C8C2C69E240BB0@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KY Srinivasan <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

T24gOC8yMS8xOCA2OjQ0IEFNLCBEYXZpZCBIaWxkZW5icmFuZCB3cm90ZToNCj4gVGhlcmUgc2Vl
bSB0byBiZSBzb21lIHByb2JsZW1zIGFzIHJlc3VsdCBvZiAzMDQ2N2UwYjNiZSAoIm1tLCBob3Rw
bHVnOg0KPiBmaXggY29uY3VycmVudCBtZW1vcnkgaG90LWFkZCBkZWFkbG9jayIpLCB3aGljaCB0
cmllZCB0byBmaXggYSBwb3NzaWJsZQ0KPiBsb2NrIGludmVyc2lvbiByZXBvcnRlZCBhbmQgZGlz
Y3Vzc2VkIGluIFsxXSBkdWUgdG8gdGhlIHR3byBsb2Nrcw0KPiAJYSkgZGV2aWNlX2xvY2soKQ0K
PiAJYikgbWVtX2hvdHBsdWdfbG9jaw0KPiANCj4gV2hpbGUgYWRkX21lbW9yeSgpIGZpcnN0IHRh
a2VzIGIpLCBmb2xsb3dlZCBieSBhKSBkdXJpbmcNCj4gYnVzX3Byb2JlX2RldmljZSgpLCBvbmxp
bmluZyBvZiBtZW1vcnkgZnJvbSB1c2VyIHNwYWNlIGZpcnN0IHRvb2sgYiksDQo+IGZvbGxvd2Vk
IGJ5IGEpLCBleHBvc2luZyBhIHBvc3NpYmxlIGRlYWRsb2NrLg0KPiANCj4gSW4gWzFdLCBhbmQg
aXQgd2FzIGRlY2lkZWQgdG8gbm90IG1ha2UgdXNlIG9mIGRldmljZV9ob3RwbHVnX2xvY2ssIGJ1
dA0KPiByYXRoZXIgdG8gZW5mb3JjZSBhIGxvY2tpbmcgb3JkZXIuDQo+IA0KPiBUaGUgcHJvYmxl
bXMgSSBzcG90dGVkIHJlbGF0ZWQgdG8gdGhpczoNCj4gDQo+IDEuIE1lbW9yeSBibG9jayBkZXZp
Y2UgYXR0cmlidXRlczogV2hpbGUgLnN0YXRlIGZpcnN0IGNhbGxzDQo+ICAgIG1lbV9ob3RwbHVn
X2JlZ2luKCkgYW5kIHRoZSBjYWxscyBkZXZpY2Vfb25saW5lKCkgLSB3aGljaCB0YWtlcw0KPiAg
ICBkZXZpY2VfbG9jaygpIC0gLm9ubGluZSBkb2VzIG5vIGxvbmdlciBjYWxsIG1lbV9ob3RwbHVn
X2JlZ2luKCksIHNvDQo+ICAgIGVmZmVjdGl2ZWx5IGNhbGxzIG9ubGluZV9wYWdlcygpIHdpdGhv
dXQgbWVtX2hvdHBsdWdfbG9jay4NCj4gDQo+IDIuIGRldmljZV9vbmxpbmUoKSBzaG91bGQgYmUg
Y2FsbGVkIHVuZGVyIGRldmljZV9ob3RwbHVnX2xvY2ssIGhvd2V2ZXINCj4gICAgb25saW5pbmcg
bWVtb3J5IGR1cmluZyBhZGRfbWVtb3J5KCkgZG9lcyBub3QgdGFrZSBjYXJlIG9mIHRoYXQuDQo+
IA0KPiBJbiBhZGRpdGlvbiwgSSB0aGluayB0aGVyZSBpcyBhbHNvIHNvbWV0aGluZyB3cm9uZyBh
Ym91dCB0aGUgbG9ja2luZyBpbg0KPiANCj4gMy4gYXJjaC9wb3dlcnBjL3BsYXRmb3Jtcy9wb3dl
cm52L21lbXRyYWNlLmMgY2FsbHMgb2ZmbGluZV9wYWdlcygpDQo+ICAgIHdpdGhvdXQgbG9ja3Mu
IFRoaXMgd2FzIGludHJvZHVjZWQgYWZ0ZXIgMzA0NjdlMGIzYmUuIEFuZCBza2ltbWluZyBvdmVy
DQo+ICAgIHRoZSBjb2RlLCBJIGFzc3VtZSBpdCBjb3VsZCBuZWVkIHNvbWUgbW9yZSBjYXJlIGlu
IHJlZ2FyZHMgdG8gbG9ja2luZw0KPiAgICAoZS5nLiBkZXZpY2Vfb25saW5lKCkgY2FsbGVkIHdp
dGhvdXQgZGV2aWNlX2hvdHBsdWdfbG9jayAtIGJ1dCBJJ2xsDQo+ICAgIG5vdCB0b3VjaCB0aGF0
IGZvciBub3cpLg0KPiANCj4gTm93IHRoYXQgd2UgaG9sZCB0aGUgZGV2aWNlX2hvdHBsdWdfbG9j
ayB3aGVuDQo+IC0gYWRkaW5nIG1lbW9yeSAoZS5nLiB2aWEgYWRkX21lbW9yeSgpL2FkZF9tZW1v
cnlfcmVzb3VyY2UoKSkNCj4gLSByZW1vdmluZyBtZW1vcnkgKGUuZy4gdmlhIHJlbW92ZV9tZW1v
cnkoKSkNCj4gLSBkZXZpY2Vfb25saW5lKCkvZGV2aWNlX29mZmxpbmUoKQ0KPiANCj4gV2UgY2Fu
IG1vdmUgbWVtX2hvdHBsdWdfbG9jayB1c2FnZSBiYWNrIGludG8NCj4gb25saW5lX3BhZ2VzKCkv
b2ZmbGluZV9wYWdlcygpLg0KPiANCj4gV2h5IGlzIG1lbV9ob3RwbHVnX2xvY2sgc3RpbGwgbmVl
ZGVkPyBFc3NlbnRpYWxseSB0byBtYWtlDQo+IGdldF9vbmxpbmVfbWVtcygpL3B1dF9vbmxpbmVf
bWVtcygpIGJlIHZlcnkgZmFzdCAocmVseWluZyBvbg0KPiBkZXZpY2VfaG90cGx1Z19sb2NrIHdv
dWxkIGJlIHZlcnkgc2xvdyksIGFuZCB0byBzZXJpYWxpemUgYWdhaW5zdA0KPiBhZGRpdGlvbiBv
ZiBtZW1vcnkgdGhhdCBkb2VzIG5vdCBjcmVhdGUgbWVtb3J5IGJsb2NrIGRldmljZXMgKGhtbSku
DQo+IA0KPiBbMV0gaHR0cDovL2RyaXZlcmRldi5saW51eGRyaXZlcnByb2plY3Qub3JnL3BpcGVy
bWFpbC8gZHJpdmVyZGV2LWRldmVsLw0KPiAgICAgMjAxNS1GZWJydWFyeS8wNjUzMjQuaHRtbA0K
PiANCj4gVGhpcyBwYXRjaCBpcyBwYXJ0bHkgYmFzZWQgb24gYSBwYXRjaCBieSBWaXRhbHkgS3V6
bmV0c292Lg0KDQpSZXZpZXdlZC1ieTogUGF2ZWwgVGF0YXNoaW4gPHBhdmVsLnRhdGFzaGluQG1p
Y3Jvc29mdC5jb20+

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30BEE6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 13:20:50 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id j189so195758097vkc.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 10:20:50 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0113.outbound.protection.outlook.com. [104.47.33.113])
        by mx.google.com with ESMTPS id q67si7646965qkq.261.2016.09.06.10.20.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 10:20:49 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Date: Tue, 6 Sep 2016 17:20:47 +0000
Message-ID: <DM2PR21MB00892878E2A17E076A18C795CBF90@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: Toshi Kani <toshi.kani@hpe.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

SSBoYXZlIG5vIG9iamVjdGlvbiB0byB0aGlzIHBhdGNoIGdvaW5nIGluIGZvciBub3cuDQoNCkxv
bmdlciB0ZXJtLCBzdXJlbHkgd2Ugd2FudCB0byB0cmFjayB3aGF0IG1vZGUgdGhlIFBGTnMgYXJl
IG1hcHBlZCBpbj8gIFRoZXJlIGFyZSB2YXJpb3VzIGJpemFycmUgc3VwcG9zaXRpb25zIG91dCB0
aGVyZSBhYm91dCBob3cgcGVyc2lzdGVudCBtZW1vcnkgc2hvdWxkIGJlIG1hcHBlZCwgYW5kIGl0
J3MgcHJvYmFibHkgYmV0dGVyIGlmIHRoZSBrZXJuZWwgaWdub3JlcyB3aGF0IHRoZSB1c2VyIHNw
ZWNpZmllcyBhbmQga2VlcHMgZXZlcnl0aGluZyBzYW5lLiAgSSd2ZSByZWFkIHRoZSBkaXJlIHdh
cm5pbmdzIGluIHRoZSBJbnRlbCBhcmNoaXRlY3R1cmUgbWFudWFsIGFuZCBJIGhhdmUgbm8gZGVz
aXJlIHRvIGRlYWwgd2l0aCB0aGUgaW5ldml0YWJsZSBidWcgcmVwb3J0cyBvbiBzb21lIGhhcmR3
YXJlIEkgZG9uJ3Qgb3duIGFuZCByZXF1aXJlcyB0d2VudHkgd2Vla3Mgb2Ygb3BlcmF0aW9uIGlu
IG9yZGVyIHRvIG9ic2VydmUgdGhlIGJ1Zy4NCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0N
CkZyb206IERhbiBXaWxsaWFtcyBbbWFpbHRvOmRhbi5qLndpbGxpYW1zQGludGVsLmNvbV0gDQpT
ZW50OiBUdWVzZGF5LCBTZXB0ZW1iZXIgNiwgMjAxNiAxMjo1MCBQTQ0KVG86IGxpbnV4LW52ZGlt
bUBsaXN0cy4wMS5vcmcNCkNjOiBUb3NoaSBLYW5pIDx0b3NoaS5rYW5pQGhwZS5jb20+OyBNYXR0
aGV3IFdpbGNveCA8bWF3aWxjb3hAbWljcm9zb2Z0LmNvbT47IE5pbGVzaCBDaG91ZGh1cnkgPG5p
bGVzaC5jaG91ZGh1cnlAb3JhY2xlLmNvbT47IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7
IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgYWtwbUBsaW51eC1m
b3VuZGF0aW9uLm9yZzsgUm9zcyBad2lzbGVyIDxyb3NzLnp3aXNsZXJAbGludXguaW50ZWwuY29t
PjsgS2lyaWxsIEEuIFNodXRlbW92IDxraXJpbGwuc2h1dGVtb3ZAbGludXguaW50ZWwuY29tPjsg
S2FpIFpoYW5nIDxrYWkua2EuemhhbmdAb3JhY2xlLmNvbT4NClN1YmplY3Q6IFtQQVRDSCA0LzVd
IG1tOiBmaXggY2FjaGUgbW9kZSBvZiBkYXggcG1kIG1hcHBpbmdzDQoNCnRyYWNrX3Bmbl9pbnNl
cnQoKSBpcyBtYXJraW5nIGRheCBtYXBwaW5ncyBhcyB1bmNhY2hlYWJsZS4NCg0KSXQgaXMgdXNl
ZCB0byBrZWVwIG1hcHBpbmdzIGF0dHJpYnV0ZXMgY29uc2lzdGVudCBhY3Jvc3MgYSByZW1hcHBl
ZCByYW5nZS4NCkhvd2V2ZXIsIHNpbmNlIGRheCByZWdpb25zIGFyZSBuZXZlciByZWdpc3RlcmVk
IHZpYSB0cmFja19wZm5fcmVtYXAoKSwgdGhlIGNhY2hpbmcgbW9kZSBsb29rdXAgZm9yIGRheCBw
Zm5zIGFsd2F5cyByZXR1cm5zIF9QQUdFX0NBQ0hFX01PREVfVUMuICBXZSBkbyBub3QgdXNlIHRy
YWNrX3Bmbl9pbnNlcnQoKSBpbiB0aGUgZGF4LXB0ZSBwYXRoLCBhbmQgd2UgYWx3YXlzIHdhbnQg
dG8gdXNlIHRoZSBwZ3Byb3Qgb2YgdGhlIHZtYSBpdHNlbGYsIHNvIGRyb3AgdGhpcyBjYWxsLg0K
DQpDYzogUm9zcyBad2lzbGVyIDxyb3NzLnp3aXNsZXJAbGludXguaW50ZWwuY29tPg0KQ2M6IE1h
dHRoZXcgV2lsY294IDxtYXdpbGNveEBtaWNyb3NvZnQuY29tPg0KQ2M6IEtpcmlsbCBBLiBTaHV0
ZW1vdiA8a2lyaWxsLnNodXRlbW92QGxpbnV4LmludGVsLmNvbT4NCkNjOiBBbmRyZXcgTW9ydG9u
IDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KQ2M6IE5pbGVzaCBDaG91ZGh1cnkgPG5pbGVz
aC5jaG91ZGh1cnlAb3JhY2xlLmNvbT4NClJlcG9ydGVkLWJ5OiBLYWkgWmhhbmcgPGthaS5rYS56
aGFuZ0BvcmFjbGUuY29tPg0KUmVwb3J0ZWQtYnk6IFRvc2hpIEthbmkgPHRvc2hpLmthbmlAaHBl
LmNvbT4NCkNjOiA8c3RhYmxlQHZnZXIua2VybmVsLm9yZz4NClNpZ25lZC1vZmYtYnk6IERhbiBX
aWxsaWFtcyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPg0KLS0tDQogbW0vaHVnZV9tZW1vcnku
YyB8ICAgIDIgLS0NCiAxIGZpbGUgY2hhbmdlZCwgMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdp
dCBhL21tL2h1Z2VfbWVtb3J5LmMgYi9tbS9odWdlX21lbW9yeS5jIGluZGV4IGE2YWJkNzZiYWE3
Mi4uMzM4ZWZmMDVjNzdhIDEwMDY0NA0KLS0tIGEvbW0vaHVnZV9tZW1vcnkuYw0KKysrIGIvbW0v
aHVnZV9tZW1vcnkuYw0KQEAgLTY3Niw4ICs2NzYsNiBAQCBpbnQgdm1mX2luc2VydF9wZm5fcG1k
KHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIsDQogDQogCWlm
IChhZGRyIDwgdm1hLT52bV9zdGFydCB8fCBhZGRyID49IHZtYS0+dm1fZW5kKQ0KIAkJcmV0dXJu
IFZNX0ZBVUxUX1NJR0JVUzsNCi0JaWYgKHRyYWNrX3Bmbl9pbnNlcnQodm1hLCAmcGdwcm90LCBw
Zm4pKQ0KLQkJcmV0dXJuIFZNX0ZBVUxUX1NJR0JVUzsNCiAJaW5zZXJ0X3Bmbl9wbWQodm1hLCBh
ZGRyLCBwbWQsIHBmbiwgcGdwcm90LCB3cml0ZSk7DQogCXJldHVybiBWTV9GQVVMVF9OT1BBR0U7
DQogfQ0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

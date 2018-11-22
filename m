Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7786B2CAA
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:50:57 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h86-v6so3642079pfd.2
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:50:57 -0800 (PST)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730058.outbound.protection.outlook.com. [40.107.73.58])
        by mx.google.com with ESMTPS id j14si15193918pfn.277.2018.11.22.10.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 10:50:56 -0800 (PST)
From: "Koenig, Christian" <Christian.Koenig@amd.com>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to
 fail
Date: Thu, 22 Nov 2018 18:50:53 +0000
Message-ID: <800ac84e-593c-31c5-cc01-2b05e877e867@amd.com>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
In-Reply-To: <20181122165106.18238-2-daniel.vetter@ffwll.ch>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <076964FFF5ABA64A8FD48047436FD562@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

QW0gMjIuMTEuMTggdW0gMTc6NTEgc2NocmllYiBEYW5pZWwgVmV0dGVyOg0KPiBKdXN0IGEgYml0
IG9mIHBhcmFub2lhLCBzaW5jZSBpZiB3ZSBzdGFydCBwdXNoaW5nIHRoaXMgZGVlcCBpbnRvDQo+
IGNhbGxjaGFpbnMgaXQncyBoYXJkIHRvIHNwb3QgYWxsIHBsYWNlcyB3aGVyZSBhbiBtbXUgbm90
aWZpZXINCj4gaW1wbGVtZW50YXRpb24gbWlnaHQgZmFpbCB3aGVuIGl0J3Mgbm90IGFsbG93ZWQg
dG8uDQo+DQo+IENjOiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0K
PiBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+DQo+IENjOiAiQ2hyaXN0aWFuIEvD
tm5pZyIgPGNocmlzdGlhbi5rb2VuaWdAYW1kLmNvbT4NCj4gQ2M6IERhdmlkIFJpZW50amVzIDxy
aWVudGplc0Bnb29nbGUuY29tPg0KPiBDYzogRGFuaWVsIFZldHRlciA8ZGFuaWVsLnZldHRlckBm
ZndsbC5jaD4NCj4gQ2M6ICJKw6lyw7RtZSBHbGlzc2UiIDxqZ2xpc3NlQHJlZGhhdC5jb20+DQo+
IENjOiBsaW51eC1tbUBrdmFjay5vcmcNCj4gQ2M6IFBhb2xvIEJvbnppbmkgPHBib256aW5pQHJl
ZGhhdC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IERhbmllbCBWZXR0ZXIgPGRhbmllbC52ZXR0ZXJA
aW50ZWwuY29tPg0KDQpBY2tlZC1ieTogQ2hyaXN0aWFuIEvDtm5pZyA8Y2hyaXN0aWFuLmtvZW5p
Z0BhbWQuY29tPg0KDQo+IC0tLQ0KPiAgIG1tL21tdV9ub3RpZmllci5jIHwgMiArKw0KPiAgIDEg
ZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKykNCj4NCj4gZGlmZiAtLWdpdCBhL21tL21tdV9u
b3RpZmllci5jIGIvbW0vbW11X25vdGlmaWVyLmMNCj4gaW5kZXggNTExOWZmODQ2NzY5Li41OWUx
MDI1ODlhMjUgMTAwNjQ0DQo+IC0tLSBhL21tL21tdV9ub3RpZmllci5jDQo+ICsrKyBiL21tL21t
dV9ub3RpZmllci5jDQo+IEBAIC0xOTAsNiArMTkwLDggQEAgaW50IF9fbW11X25vdGlmaWVyX2lu
dmFsaWRhdGVfcmFuZ2Vfc3RhcnQoc3RydWN0IG1tX3N0cnVjdCAqbW0sDQo+ICAgCQkJCXByX2lu
Zm8oIiVwUyBjYWxsYmFjayBmYWlsZWQgd2l0aCAlZCBpbiAlc2Jsb2NrYWJsZSBjb250ZXh0Llxu
IiwNCj4gICAJCQkJCQltbi0+b3BzLT5pbnZhbGlkYXRlX3JhbmdlX3N0YXJ0LCBfcmV0LA0KPiAg
IAkJCQkJCSFibG9ja2FibGUgPyAibm9uLSIgOiAiIik7DQo+ICsJCQkJV0FSTihibG9ja2FibGUs
IiVwUyBjYWxsYmFjayBmYWlsdXJlIG5vdCBhbGxvd2VkXG4iLA0KPiArCQkJCSAgICAgbW4tPm9w
cy0+aW52YWxpZGF0ZV9yYW5nZV9zdGFydCk7DQo+ICAgCQkJCXJldCA9IF9yZXQ7DQo+ICAgCQkJ
fQ0KPiAgIAkJfQ0KDQo=

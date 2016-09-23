Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4866B0286
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:44:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so54694057lfb.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:44:55 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.189])
        by mx.google.com with ESMTPS id o140si3170017lff.163.2016.09.23.02.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 02:44:53 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Fri, 23 Sep 2016 09:42:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
In-Reply-To: <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>

RnJvbTogVmxhc3RpbWlsIEJhYmthDQo+IFNlbnQ6IDIyIFNlcHRlbWJlciAyMDE2IDE4OjU1DQou
Li4NCj4gU28gaW4gdGhlIGNhc2Ugb2Ygc2VsZWN0KCkgaXQgc2VlbXMgbGlrZSB0aGUgbWVtb3J5
IHdlIG5lZWQgNiBiaXRzIHBlciBmaWxlDQo+IGRlc2NyaXB0b3IsIG11bHRpcGxpZWQgYnkgdGhl
IGhpZ2hlc3QgcG9zc2libGUgZmlsZSBkZXNjcmlwdG9yIChuZmRzKSBhcyBwYXNzZWQNCj4gdG8g
dGhlIHN5c2NhbGwuIEFjY29yZGluZyB0byB0aGUgbWFuIHBhZ2Ugb2Ygc2VsZWN0Og0KPiANCj4g
ICAgICAgICBFSU5WQUwgbmZkcyBpcyBuZWdhdGl2ZSBvciBleGNlZWRzIHRoZSBSTElNSVRfTk9G
SUxFIHJlc291cmNlIGxpbWl0IChzZWUNCj4gZ2V0cmxpbWl0KDIpKS4NCg0KVGhhdCBzZWNvbmQg
Y2xhdXNlIGlzIHJlbGF0aXZlbHkgcmVjZW50Lg0KDQo+IFRoZSBjb2RlIGFjdHVhbGx5IHNlZW1z
IHRvIHNpbGVudGx5IGNhcCB0aGUgdmFsdWUgaW5zdGVhZCBvZiByZXR1cm5pbmcgRUlOVkFMDQo+
IHRob3VnaD8gKElJVUMpOg0KPiANCj4gICAgICAgICAvKiBtYXhfZmRzIGNhbiBpbmNyZWFzZSwg
c28gZ3JhYiBpdCBvbmNlIHRvIGF2b2lkIHJhY2UgKi8NCj4gICAgICAgICAgcmN1X3JlYWRfbG9j
aygpOw0KPiAgICAgICAgICBmZHQgPSBmaWxlc19mZHRhYmxlKGN1cnJlbnQtPmZpbGVzKTsNCj4g
ICAgICAgICAgbWF4X2ZkcyA9IGZkdC0+bWF4X2ZkczsNCj4gICAgICAgICAgcmN1X3JlYWRfdW5s
b2NrKCk7DQo+ICAgICAgICAgIGlmIChuID4gbWF4X2ZkcykNCj4gICAgICAgICAgICAgICAgICBu
ID0gbWF4X2ZkczsNCj4gDQo+IFRoZSBkZWZhdWx0IGZvciB0aGlzIGNhcCBzZWVtcyB0byBiZSAx
MDI0IHdoZXJlIEkgY2hlY2tlZCAoYWdhaW4sIElJVUMsIGl0J3MNCj4gd2hhdCB1bGltaXQgLW4g
cmV0dXJucz8pLiBJIHdhc24ndCBhYmxlIHRvIGNoYW5nZSBpdCB0byBtb3JlIHRoYW4gMjA0OCwg
d2hpY2gNCj4gbWFrZXMgdGhlIGJpdG1hcHMgc3RpbGwgYmVsb3cgUEFHRV9TSVpFLg0KPiANCj4g
U28gaWYgSSBnZXQgdGhhdCByaWdodCwgdGhlIHN5c3RlbSBhZG1pbiB3b3VsZCBoYXZlIHRvIGFs
bG93IHJlYWxseSBsYXJnZQ0KPiBSTElNSVRfTk9GSUxFIHRvIGV2ZW4gbWFrZSB2bWFsbG9jKCkg
cG9zc2libGUgaGVyZS4gU28gSSBkb24ndCBzZWUgaXQgYXMgYSBsYXJnZQ0KPiBjb25jZXJuPw0K
DQo0ayBvcGVuIGZpbGVzIGlzbid0IHRoYXQgbWFueS4NCkVzcGVjaWFsbHkgZm9yIHByb2dyYW1z
IHRoYXQgYXJlIHVzaW5nIHBpcGVzIHRvIGVtdWxhdGUgd2luZG93cyBldmVudHMuDQoNCkkgc3Vz
cGVjdCB0aGF0IGZkdC0+bWF4X2ZkcyBpcyBhbiB1cHBlciBib3VuZCBmb3IgdGhlIGhpZ2hlc3Qg
ZmQgdGhlDQpwcm9jZXNzIGhhcyBvcGVuIC0gbm90IHRoZSBSTElNSVRfTk9GSUxFIHZhbHVlLg0K
c2VsZWN0KCkgc2hvdWxkbid0IGJlIHNpbGVudGx5IGlnbm9yaW5nIGxhcmdlIHZhbHVlcyBvZiAn
bicgdW5sZXNzDQp0aGUgZmRfc2V0IGJpdHMgYXJlIHplcm8uDQoNCk9mIGNvdXJzZSwgc2VsZWN0
IGRvZXMgc2NhbGUgd2VsbCBmb3IgaGlnaCBudW1iZXJlZCBmZHMNCmFuZCBuZWl0aGVyIHBvbGwg
bm9yIHNlbGVjdCBzY2FsZSB3ZWxsIGZvciBsYXJnZSBudW1iZXJzIG9mIGZkcy4NCg0KCURhdmlk
DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

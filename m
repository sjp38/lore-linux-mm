Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4126F6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:27:20 -0500 (EST)
From: James Bottomley <jbottomley@parallels.com>
Subject: Re: [Devel] Re: [PATCH v5 00/10] per-cgroup tcp memory pressure
Date: Tue, 15 Nov 2011 18:27:12 +0000
Message-ID: <1321381632.3021.57.camel@dabdike.int.hansenpartnership.com>
References: <1320679595-21074-1-git-send-email-glommer@parallels.com>
	 <4EBAC04F.1010901@parallels.com>
In-Reply-To: <4EBAC04F.1010901@parallels.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1EAD5527F120CB4E80CCB5C5CB27495B@sw.swsoft.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "davem@davemloft.net" <davem@davemloft.net>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "paul@paulmenage.org" <paul@paulmenage.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "devel@openvz.org" <devel@openvz.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "gthelen@google.com" <gthelen@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

T24gV2VkLCAyMDExLTExLTA5IGF0IDE2OjAyIC0wMjAwLCBHbGF1YmVyIENvc3RhIHdyb3RlOg0K
PiBPbiAxMS8wNy8yMDExIDAxOjI2IFBNLCBHbGF1YmVyIENvc3RhIHdyb3RlOg0KPiA+IEhpIGFs
bCwNCj4gPg0KPiA+IFRoaXMgaXMgbXkgbmV3IGF0dGVtcHQgYXQgaW1wbGVtZW50aW5nIHBlci1j
Z3JvdXAgdGNwIG1lbW9yeSBwcmVzc3VyZS4NCj4gPiBJIGFtIHBhcnRpY3VsYXJseSBpbnRlcmVz
dGVkIGluIHdoYXQgdGhlIG5ldHdvcmsgZm9sa3MgaGF2ZSB0byBjb21tZW50IG9uDQo+ID4gaXQ6
IG15IG1haW4gZ29hbCBpcyB0byBhY2hpZXZlIHRoZSBsZWFzdCBpbXBhY3QgcG9zc2libGUgaW4g
dGhlIG5ldHdvcmsgY29kZS4NCj4gPg0KPiA+IEhlcmUncyBhIGJyaWVmIGRlc2NyaXB0aW9uIG9m
IG15IGFwcHJvYWNoOg0KPiA+DQo+ID4gV2hlbiBvbmx5IHRoZSByb290IGNncm91cCBpcyBwcmVz
ZW50LCB0aGUgY29kZSBzaG91bGQgYmVoYXZlIHRoZSBzYW1lIHdheSBhcw0KPiA+IGJlZm9yZSAt
IHdpdGggdGhlIGV4Y2VwdGlvbiBvZiB0aGUgaW5jbHVzaW9uIG9mIGFuIGV4dHJhIGZpZWxkIGlu
IHN0cnVjdCBzb2NrLA0KPiA+IGFuZCBvbmUgaW4gc3RydWN0IHByb3RvLiBBbGwgdGVzdHMgYXJl
IHBhdGNoZWQgb3V0IHdpdGggc3RhdGljIGJyYW5jaCwgYW5kIHdlDQo+ID4gc3RpbGwgYWNjZXNz
IGFkZHJlc3NlcyBkaXJlY3RseSAtIHRoZSBzYW1lIGFzIHdlIGRpZCBiZWZvcmUuDQo+ID4NCj4g
PiBXaGVuIGEgY2dyb3VwIG90aGVyIHRoYW4gcm9vdCBpcyBjcmVhdGVkLCB3ZSBwYXRjaCBpbiB0
aGUgYnJhbmNoZXMsIGFuZCBhY2NvdW50DQo+ID4gcmVzb3VyY2VzIGZvciB0aGF0IGNncm91cC4g
VGhlIHZhcmlhYmxlcyBpbiB0aGUgcm9vdCBjZ3JvdXAgYXJlIHN0aWxsIHVwZGF0ZWQuDQo+ID4g
SWYgd2Ugd2VyZSB0byB0cnkgdG8gYmUgMTAwICUgY29oZXJlbnQgd2l0aCB0aGUgbWVtY2cgY29k
ZSwgdGhhdCBzaG91bGQgZGVwZW5kDQo+ID4gb24gdXNlX2hpZXJhcmNoeS4gSG93ZXZlciwgSSBm
ZWVsIHRoYXQgdGhpcyBpcyBhIGdvb2QgY29tcHJvbWlzZSBpbiB0ZXJtcyBvZg0KPiA+IGxlYXZp
bmcgdGhlIG5ldHdvcmsgY29kZSB1bnRvdWNoZWQsIGFuZCBzdGlsbCBoYXZpbmcgYSBnbG9iYWwg
dmlzaW9uIG9mIGl0cw0KPiA+IHJlc291cmNlcy4gSSBhbHNvIGRvIG5vdCBjb21wdXRlIG1heF91
c2FnZSBmb3IgdGhlIHJvb3QgY2dyb3VwLCBmb3IgYSBzaW1pbGFyDQo+ID4gcmVhc29uLg0KPiA+
DQo+ID4gUGxlYXNlIGxldCBtZSBrbm93IHdoYXQgeW91IHRoaW5rIG9mIGl0Lg0KPiANCj4gRGF2
ZSwgRXJpYywNCj4gDQo+IENhbiB5b3UgbGV0IG1lIGtub3cgd2hhdCB5b3UgdGhpbmsgb2YgdGhl
IGdlbmVyYWwgYXBwcm9hY2ggSSd2ZSBmb2xsb3dlZCANCj4gaW4gdGhpcyBzZXJpZXM/IFRoZSBp
bXBhY3Qgb24gdGhlIGNvbW1vbiBjYXNlIHNob3VsZCBiZSBtaW5pbWFsLCBvciBhdCANCj4gbGVh
c3QgYXMgZXhwZW5zaXZlIGFzIGEgc3RhdGljIGJyYW5jaCAoMCBpbiBtb3N0IGFyY2hlcywgSSBi
ZWxpZXZlKS4NCj4gDQo+IEkgYW0gbW9zdGx5IGludGVyZXN0ZWQgaW4ga25vd2luZyBpZiB0aGlz
IGEgdmFsaWQgcHVyc3VlIHBhdGguIEknbGwgYmUgDQo+IGhhcHB5IHRvIGFkZHJlc3MgYW55IHNw
ZWNpZmljIGNvbmNlcm5zIHlvdSBoYXZlIG9uY2UgeW91J3JlIG9rIHdpdGggdGhlIA0KPiBnZW5l
cmFsIGFwcHJvYWNoLg0KDQpQaW5nIG9uIHRoaXMsIHBsZWFzZS4gIFdlJ3JlIGJsb2NrZWQgb24g
dGhpcyBwYXRjaCBzZXQgdW50aWwgd2UgY2FuIGdldA0KYW4gYWNrIHRoYXQgdGhlIGFwcHJvYWNo
IGlzIGFjY2VwdGFibGUgdG8gbmV0d29yayBwZW9wbGUuDQoNClRoYW5rcywNCg0KSmFtZXMNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

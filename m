Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 323096B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 03:29:00 -0400 (EDT)
From: James Bottomley <jbottomley@parallels.com>
Subject: Re: [Devel] Re: [PATCH v3 13/28] slub: create duplicate cache
Date: Wed, 30 May 2012 07:28:26 +0000
Message-ID: <1338362906.3229.4.camel@dabdike>
References: <alpine.DEB.2.00.1205291101580.6723@router.home>
	 <4FC501E9.60607@parallels.com>
	 <alpine.DEB.2.00.1205291222360.8495@router.home>
	 <4FC506E6.8030108@parallels.com>
	 <alpine.DEB.2.00.1205291424130.8495@router.home>
	 <4FC52612.5060006@parallels.com>
	 <alpine.DEB.2.00.1205291454030.2504@router.home>
	 <4FC52CC6.7020109@parallels.com>
	 <alpine.DEB.2.00.1205291514090.2504@router.home>
	 <4FC530C0.30509@parallels.com> <20120530012955.GA4854@google.com>
In-Reply-To: <20120530012955.GA4854@google.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <09D17D0C0938FA4987E8804C68CDC32A@sw.swsoft.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Suleiman Souhlal <suleiman@google.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, "devel@openvz.org" <devel@openvz.org>, Greg Thelen <gthelen@google.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

T24gV2VkLCAyMDEyLTA1LTMwIGF0IDEwOjI5ICswOTAwLCBUZWp1biBIZW8gd3JvdGU6DQo+IEhl
bGxvLCBDaHJpc3RvcGgsIEdsYXViZXIuDQo+IA0KPiBPbiBXZWQsIE1heSAzMCwgMjAxMiBhdCAx
MjoyNTozNkFNICswNDAwLCBHbGF1YmVyIENvc3RhIHdyb3RlOg0KPiA+ID5XZSBoYXZlIG5ldmVy
IHdvcmtlZCBjb250YWluZXIgbGlrZSBsb2dpYyBsaWtlIHRoYXQgaW4gdGhlIGtlcm5lbCBkdWUg
dG8NCj4gPiA+dGhlIGNvbXBsaWNhdGVkIGxvZ2ljIHlvdSB3b3VsZCBoYXZlIHRvIHB1dCBpbi4g
VGhlIHJlcXVpcmVtZW50IHRoYXQgYWxsDQo+ID4gPm9iamVjdHMgaW4gYSBwYWdlIGNvbWUgZnJv
bSB0aGUgc2FtZSBjb250YWluZXIgaXMgbm90IG5lY2Vzc2FyeS4gSWYgeW91DQo+ID4gPmRyb3Ag
dGhpcyBub3Rpb24gdGhlbiB0aGluZ3MgYmVjb21lIHZlcnkgZWFzeSBhbmQgdGhlIHBhdGNoZXMg
d2lsbCBiZWNvbWUNCj4gPiA+c2ltcGxlLg0KPiA+IA0KPiA+IEkgcHJvbWlzZSB0byBsb29rIGF0
IHRoYXQgaW4gbW9yZSBkZXRhaWwgYW5kIGdldCBiYWNrIHRvIGl0LiBJbiB0aGUNCj4gPiBtZWFu
dGltZSwgSSB0aGluayBpdCB3b3VsZCBiZSBlbmxpZ2h0ZW5pbmcgdG8gaGVhciBmcm9tIG90aGVy
DQo+ID4gcGFydGllcyBhcyB3ZWxsLCBzcGVjaWFsbHkgdGhlIG9uZXMgYWxzbyBkaXJlY3RseSBp
bnRlcmVzdGVkIGluDQo+ID4gdXNpbmcgdGhlIHRlY2hub2xvZ3kuDQo+IA0KPiBJIGRvbid0IHRo
aW5rIEknbSB0b28gaW50ZXJlc3RlZCBpbiB1c2luZyB0aGUgdGVjaG5vbG9neSA7KSBhbmQNCj4g
aGF2ZW4ndCByZWFkIHRoZSBjb2RlIChqdXN0IGdsYW5jZWQgdGhyb3VnaCB0aGUgZGVzY3JpcHRp
b25zIGFuZA0KPiBkaXNjdXNzaW9ucyksIGJ1dCwgaW4gZ2VuZXJhbCwgSSB0aGluayB0aGUgYXBw
cm9hY2ggb2YgZHVwbGljYXRpbmcNCj4gbWVtb3J5IGFsbG9jYXRvciBwZXItbWVtY2cgaXMgYSBz
YW5lIGFwcHJvYWNoLiAgSXQgaXNuJ3QgdGhlIG1vc3QNCj4gZWZmaWNpZW50IG9uZSB3aXRoIHRo
ZSBwb3NzaWJpbGl0eSBvZiB3YXN0aW5nIGNvbnNpZGVyYWJsZSBhbW91bnQgb2YNCj4gY2FjaGlu
ZyBhcmVhIHBlciBtZW1jZyBidXQgaXQgaXMgc29tZXRoaW5nIHdoaWNoIGNhbiBtb3N0bHkgc3Rh
eSBvdXQNCj4gb2YgdGhlIHdheSBpZiBkb25lIHJpZ2h0IGFuZCB0aGF0J3MgaG93IEkgd2FudCBj
Z3JvdXAgaW1wbGVtZW50YXRpb25zDQo+IHRvIGJlLg0KDQpFeGFjdGx5OiB3ZSBhdCBwYXJhbGxl
bHMgaW5pdGlhbGx5IGRpc2xpa2VkIHRoZSBjZ3JvdXAgbXVsdGlwbGVkIGJ5IHNsYWINCmFwcHJv
YWNoIChPdXIgYmVhbmNvdW50ZXJzIGRvIGNvdW50IG9iamVjdHMpIGJlY2F1c2Ugd2UgZmVhcmVk
IG1lbW9yeQ0Kd2FzdGFnZSBhbmQgZGVuc2l0eSBpcyB2ZXJ5IGltcG9ydGFudCB0byB1cyAod2hp
Y2ggdGVuZHMgdG8gbWVhbg0KZWZmaWNpZW50IHVzZSBvZiBtZW1vcnkpIGhvd2V2ZXIsIHdoZW4g
d2UgcmFuIHRocm91Z2ggdGhlIGNhbGN1bGF0aW9ucw0KaW4gUHJhZ3VlLCB5b3UgY2FuIHNob3cg
dGhhdCB3ZSBoYXZlIH4yMDAgc2xhYnMgYW5kIGlmIGVhY2ggd2FzdGVzIGhhbGYNCmEgcGFnZSwg
dGhhdHMgfjRNQiBtZW1vcnkgbG9zdCBwZXIgY29udGFpbmVyLiAgU2luY2UgbW9zdCB2aXJ0dWFs
DQplbnZpcm9ubWVudHMgYXJlIG9mIHRoZSBvcmRlciBub3dhZGF5cyBvZiAwLjVHQiwgd2UgZmVl
bCBpdCdzIGFuDQphbm5veWluZyBidXQgYWNjZXB0YWJsZSBwcmljZSB0byBwYXkuDQoNCkphbWVz
DQoNCj4gVGhlIHR3byBnb2FscyBmb3IgY2dyb3VwIGNvbnRyb2xsZXJzIHRoYXQgSSB0aGluayBh
cmUgaW1wb3J0YW50IGFyZQ0KPiBwcm9wZXIgKG5vLCBub3QgY3JhenkgcGVyZmVjdCBidXQgZ29v
ZCBlbm91Z2gpIGlzb2xhdGlvbiBhbmQgYW4NCj4gaW1wbGVtZW50YXRpb24gd2hpY2ggZG9lc24n
dCBpbXBhY3QgIWNnIHBhdGggaW4gYW4gaW50cnVzaXZlIG1hbm5lciAtDQo+IGlmIHNvbWVvbmUg
d2hvIGRvZXNuJ3QgY2FyZSBhYm91dCBjZ3JvdXAgYnV0IGtub3dzIGFuZCB3YW50cyB0byB3b3Jr
DQo+IG9uIHRoZSBzdWJzeXN0ZW0gc2hvdWxkIGJlIGFibGUgdG8gbW9zdGx5IGlnbm9yZSBjZ3Jv
dXAgc3VwcG9ydC4gIElmDQo+IHRoYXQgbWVhbnMgb3ZlcmhlYWQgZm9yIGNncm91cCB1c2Vycywg
c28gYmUgaXQuDQo+IA0KPiBXaXRob3V0IGxvb2tpbmcgYXQgdGhlIGFjdHVhbCBjb2RlLCBteSBy
YWluYm93LWZhcnRpbmcgdW5pY29ybiBoZXJlDQo+IHdvdWxkIGJlIGhhdmluZyBhIGNvbW1vbiBz
bFhiIGludGVyZmFjZSBsYXllciB3aGljaCBoYW5kbGVzDQo+IGludGVyZmFjaW5nIHdpdGggbWVt
b3J5IGFsbG9jYXRvciB1c2VycyBhbmQgY2dyb3VwIGFuZCBsZXQgc2xYYg0KPiBpbXBsZW1lbnQg
dGhlIHNhbWUgYmFja2VuZCBpbnRlcmZhY2Ugd2hpY2ggZG9lc24ndCBjYXJlIC8ga25vdyBhYm91
dA0KPiBjZ3JvdXAgYXQgYWxsIChvdGhlciB0aGFuIHVzaW5nIHRoZSBjb3JyZWN0IGFsbG9jYXRp
b24gY29udGV4dCwgdGhhdA0KPiBpcykuICBHbGF1YmVyLCB3b3VsZCBzb21ldGhpbmcgbGlrZSB0
aGF0IGJlIHBvc3NpYmxlPw0KPiANCj4gVGhhbmtzLg0KPiANCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

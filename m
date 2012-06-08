Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 844EB6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 07:03:44 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 11:03:29 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7C35@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608084105.GA9883@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608103501.GA15827@lizard>
In-Reply-To: <20120608103501.GA15827@lizard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cbouatmailru@gmail.com
Cc: kosaki.motohiro@gmail.com, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBleHQgQW50b24gVm9yb250c292
IFttYWlsdG86Y2JvdWF0bWFpbHJ1QGdtYWlsLmNvbV0NCj4gU2VudDogMDggSnVuZSwgMjAxMiAx
MzozNQ0KLi4uDQo+ID4gQ29udGV4dCBzd2l0Y2hlcywgcGFyc2luZywgYWN0aXZpdHkgaW4gdXNl
cnNwYWNlIGV2ZW4gbWVtb3J5IHNpdHVhdGlvbiBpcw0KPiBub3QgY2hhbmdlZC4NCj4gDQo+IFN1
cmUsIHRoZXJlIGlzIHNvbWUgYWRkaXRpb25hbCBvdmVyaGVhZC4gSSdtIGp1c3Qgc2F5aW5nIHRo
YXQgaXQgaXMgbm90IGRyYXN0aWMuIEl0DQo+IHdvdWxkIGJlIGxpa2UgMTAwIHNwcmludGZzICsg
MTAwIHNzY2FuZnMgKyAyIGNvbnRleHQgc3dpdGNoZXM/IFdlbGwsIGl0IGlzDQo+IHVuZm9ydHVu
YXRlLi4uIGJ1dCBjb21lIG9uLCB0b2RheSdzIHBob25lcyBhcmUgcnVubmluZyBYMTEgYW5kIEph
dmEuIDotKQ0KDQpWbXN0YXQgZ2VuZXJhdGlvbiBpcyBub3Qgc28gdHJpdmlhbC4gTWVtaW5mbyBo
YXMgZXZlbiBoaWdoZXIgb3ZlcmhlYWQuIEkganVzdCBjaGVja2VkIGdlbmVyYXRpb24gdGltZSB1
c2luZyBpZGxpbmcgZGV2aWNlIGFuZCBvcGVuL3JlYWQgdGVzdDoNCi0gdm1zdGF0IG1pbiAzMCwg
YXZnIDk0IG1heCAyNzQ2IHVTZWNvbmRzDQotIG1lbWluZm8gbWluIDMwLCBhdmVyYWdlIDY1IG1h
eCAxNTk2MSB1U2Vjb25kcw0KDQpJbiBjb21wYXJpc29uIC9wcm9jL3ZlcnNpb24gZm9yIHRoZSBz
YW1lIGNvbmRpdGlvbnM6IG1pbiAzMCwgYXZlcmFnZSA0MSwgbWF4IDE1MDUgdVNlY29uZHMNCiAN
Cj4gPiBJbiBrZXJuZWwgc3BhY2UgeW91IGNhbiB1c2Ugc2xpZGluZyB0aW1lciAoaW5jcmVhc2lu
ZyBpbnRlcnZhbCkgKyBzaGlua2VyLg0KPiANCj4gV2VsbCwgdy8gTWluY2hhbidzIGlkZWEsIHdl
IGNhbiBnZXQgc2hyaW5rZXIgbm90aWZpY2F0aW9ucyBpbnRvIHRoZSB1c2VybGFuZCwNCj4gc28g
dGhlIHNsaWRpbmcgdGltZXIgdGhpbmcgd291bGQgYmUgc3RpbGwgcG9zc2libGUuDQoNCk9ubHkg
YXMgYSBwb3N0LXNjaHJpbmtlciBhY3Rpb25zLiBJbiBjYXNlIG9mIG1lbW9yeSBzdHJlc3Npbmcg
b3IgY2xvc2UtdG8tc3RyZXNzaW5nIGNvbmRpdGlvbnMgc2hyaW5rZXJzIGNhbGxlZCB2ZXJ5IG9m
dGVuLCBJIHNhdyB1cCB0byA1MCB0aW1lcyBwZXIgc2Vjb25kLg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

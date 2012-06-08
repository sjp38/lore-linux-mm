Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DFAF26B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:57:34 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 08:57:13 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608084105.GA9883@lizard>
In-Reply-To: <20120608084105.GA9883@lizard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anton.vorontsov@linaro.org
Cc: kosaki.motohiro@gmail.com, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBleHQgQW50b24gVm9yb250c292
IFttYWlsdG86YW50b24udm9yb250c292QGxpbmFyby5vcmddDQo+IFNlbnQ6IDA4IEp1bmUsIDIw
MTIgMTE6NDENCi4uLg0KPiA+IFJpZ2h0LiBJdCBidXQgaXQgaGFzIGRyYXdiYWNrcyBhcyB3ZWxs
IGUuZy4gZW5zdXJlIHRoYXQgZGFlbW9uIHNjaGVkdWxlZA0KPiBwcm9wZXJseSBhbmQgcHJvcGFn
YXRlIHJlYWN0aW9uIGRlY2lzaW9uIG91dHNpZGUgdWxta2QuDQo+IA0KPiBObywgdWxta2QgaXRz
ZWxmIHByb3BhZ2F0ZXMgdGhlIGRlY2lzaW9uIChpLmUuIGl0IGtpbGxzIHByb2Nlc3NlcykuDQoN
ClRoYXQgaXMgYSBkZWNpc2lvbiAic2VsZWN0ICYga2lsbCIgOikNClByb3BhZ2F0aW9uIG9mIHRo
aXMgZGVjaXNpb24gcmVxdWlyZWQgdGltZS4gTm90IGFsbCBwcm9jZXNzZXMgY291bGQgYmUga2ls
bGVkLiBZb3UgbWF5IHN0dWNrIGluIGtpbGxpbmcgaW4gc29tZSBjYXNlcy4NCi4uLg0KPiBJbiB1
bG1rZCBJIGRvbid0IHVzZSB0aW1lcnMgYXQgYWxsLCBhbmQgYnkgIndhdGNoZXIiIEkgbWVhbiB0
aGUgc29tZQ0KPiB1c2Vyc3BhY2UgZGFlbW9uIHRoYXQgcmVjZWl2ZXMgbG93bWVtb3J5L3ByZXNz
dXJlIGV2ZW50cyAoaW4gb3VyIGNhc2UgaXQNCj4gaXMgdWxta2QpLg0KDQpUaGFua3MgZm9yIGlu
Zm8uDQoNCj4gSWYgd2Ugc3RhcnQgInBvbGxpbmciIG9uIC9wcm9jL3Ztc3RhdCB2aWEgdXNlcmxh
bmQgZGVmZXJyZWQgdGltZXJzLCB0aGF0IHdvdWxkDQo+IGJlIGEgc2luZ2xlIHRpbWVyLCBqdXN0
IGxpa2UgaW4gdm1ldmVudCBjYXNlLiBTbywgSSdtIG5vdCBzdXJlIHdoYXQgaXMgdGhlDQo+IGRp
ZmZlcmVuY2U/Li4NCg0KQ29udGV4dCBzd2l0Y2hlcywgcGFyc2luZywgYWN0aXZpdHkgaW4gdXNl
cnNwYWNlIGV2ZW4gbWVtb3J5IHNpdHVhdGlvbiBpcyBub3QgY2hhbmdlZC4gSW4ga2VybmVsIHNw
YWNlIHlvdSBjYW4gdXNlIHNsaWRpbmcgdGltZXIgKGluY3JlYXNpbmcgaW50ZXJ2YWwpICsgc2hp
bmtlci4NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

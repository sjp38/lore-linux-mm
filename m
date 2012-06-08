Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 8A12D6B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 08:25:21 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 12:25:11 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7D2B@008-AM1MPN1-004.mgdnok.nokia.com>
References: <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608084105.GA9883@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7B01@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608103501.GA15827@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7C35@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608121334.GA20772@lizard>
In-Reply-To: <20120608121334.GA20772@lizard>
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
MTIgMTU6MTQNCj4gVG86IE1vaXNlaWNodWsgTGVvbmlkIChOb2tpYS1NUC9Fc3BvbykNCi4uLg0K
PiBIbS4gSSB3b3VsZCBleHBlY3QgdGhhdCBhdmcgdmFsdWUgZm9yIG1lbWluZm8gd2lsbCBiZSBt
dWNoIHdvcnNlIHRoYW4NCj4gdm1zdGF0IChtZW1pbmZvIGdyYWJzIHNvbWUgbG9ja3MpLg0KPiAN
Cj4gT0ssIGlmIHdlIGNvbnNpZGVyIDEwMG1zIGludGVydmFsLCB0aGVuIHRoaXMgd291bGQgYmUg
bGlrZSAwLjElIG92ZXJoZWFkPw0KPiBOb3QgZ3JlYXQsIGJ1dCBzdGlsbCBiZXR0ZXIgdGhhbiBt
ZW1jZzoNCj4gDQo+IGh0dHA6Ly9sa21sLm9yZy9sa21sLzIwMTEvMTIvMjEvNDg3DQoNClRoYXQg
aXMgZGlmZmljdWx0IHRvIHdpbiBvdmVyIG1lbWNnIDopDQpCdXQgaW4gY29tcGFyaXNvbiB0byBv
bmUgc3lzY2FsbCBsaWtlIHJlYWQoKSBmb3Igc21hbGwgc3RydWN0dXJlIGZvciBwYXJ0aWN1bGFy
IGRldmljZSB0aGUgZ2VuZXJhdGlvbiBvZiBtZW1pbmZvIGlzIGFib3V0IDEwMDB4IHRpbWVzIG1v
cmUgZXhwZW5zaXZlLg0KDQo+IFNvLCBJIGd1ZXNzIHRoZSByaWdodCBhcHByb2FjaCB3b3VsZCBi
ZSB0byBmaW5kIHdheXMgdG8gbm90IGRlcGVuZCBvbg0KPiBmcmVxdWVudCB2bV9zdGF0IHVwZGF0
ZXMgKGFuZCB0aHVzIHJlYWRzKS4NCg0KQWdyZWUuDQoNCj4gdXNlcmxhbmQgZGVmZXJyZWQgdGlt
ZXJzIChhbmQgaW5mcmVxdWVudCByZWFkcyBmcm9tIHZtc3RhdCkgKyAidXNlcmxhbmQgdm0NCj4g
cHJlc3N1cmUgbm90aWZpY2F0aW9ucyIgbG9va3MgcHJvbWlzaW5nIGZvciB0aGUgdXNlcmxhbmQg
c29sdXRpb24uDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C7CCD6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:08:25 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 07:05:46 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
In-Reply-To: <20120608065828.GA1515@lizard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anton.vorontsov@linaro.org, kosaki.motohiro@gmail.com, penberg@kernel.org
Cc: b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBleHQgQW50b24gVm9yb250c292
IFttYWlsdG86YW50b24udm9yb250c292QGxpbmFyby5vcmddDQo+IFNlbnQ6IDA4IEp1bmUsIDIw
MTIgMDk6NTgNCi4uLg0KPiBJZiB5b3UncmUgc2F5aW5nIHRoYXQgd2Ugc2hvdWxkIHNldCB1cCBh
IHRpbWVyIGluIHRoZSB1c2VybGFuZCBhbmQgY29uc3RhbnRseQ0KPiByZWFkIC9wcm9jL3Ztc3Rh
dCwgdGhlbiB3ZSB3aWxsIGNhdXNlIENQVSB3YWtlIHVwIGV2ZXJ5IDEwMG1zLCB3aGljaCBpcw0K
PiBub3QgYWNjZXB0YWJsZS4gV2VsbCwgd2UgY2FuIHRyeSB0byBpbnRyb2R1Y2UgZGVmZXJyYWJs
ZSB0aW1lcnMgZm9yIHRoZQ0KPiB1c2Vyc3BhY2UuIEJ1dCB0aGVuIGl0IHdvdWxkIHN0aWxsIGFk
ZCBhIGxvdCBtb3JlIG92ZXJoZWFkIGZvciBvdXIgdGFzaywgYXMgdGhpcw0KPiBzb2x1dGlvbiBh
ZGRzIG90aGVyIHR3byBjb250ZXh0IHN3aXRjaGVzIHRvIHJlYWQgYW5kIHBhcnNlIC9wcm9jL3Zt
c3RhdC4gSQ0KPiBndWVzcyB0aGlzIGlzIG5vdCBhIHNob3ctc3RvcHBlciB0aG91Z2gsIHNvIHdl
IGNhbiBkaXNjdXNzIHRoaXMuDQo+IA0KPiBMZW9uaWQsIFBla2thLCB3aGF0IGRvIHlvdSB0aGlu
ayBhYm91dCB0aGUgaWRlYT8NCg0KU2VlbXMgdG8gbWUgbm90IG5pY2Ugc29sdXRpb24uIEdlbmVy
YXRpbmcvcGFyc2luZyB2bXN0YXQgZXZlcnkgMTAwbXMgcGx1cyB3YWtldXBzIGl0IGlzIHdoYXQg
ZXhhY3RseSBzaG91bGQgYmUgYXZvaWQgdG8gaGF2ZSBzZW5zZSB0byBBUEkuDQpJdCBhbHNvIHdp
bGwgY2F1c2UgcGFnZSB0cmFzaGluZyBiZWNhdXNlIHVzZXItc3BhY2UgY29kZSBjb3VsZCBiZSBw
dXNoZWQgb3V0IGZyb20gY2FjaGUgaWYgVk0gZGVjaWRlLiANCg0KPiANCj4gVGhhbmtzLA0KPiAN
Cj4gLS0NCj4gQW50b24gVm9yb250c292DQo+IEVtYWlsOiBjYm91YXRtYWlscnVAZ21haWwuY29t
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

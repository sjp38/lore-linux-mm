Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7A98A6B0071
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:16:17 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 08:16:04 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7A24@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <20120608075844.GA6362@lizard>
In-Reply-To: <20120608075844.GA6362@lizard>
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
MTIgMTA6NTkNCi4uLiANCj4gYSkgVHdvIG1vcmUgY29udGV4dCBzd3RpY2hlczsNCj4gYikgU2Vy
aWFsaXphdGlvbi9kZXNlcmlhbGl6YXRpb24gb2YgL3Byb2Mvdm1zdGF0Lg0KPiANCj4gPiBJdCBh
bHNvIHdpbGwgY2F1c2UgcGFnZSB0cmFzaGluZyBiZWNhdXNlIHVzZXItc3BhY2UgY29kZSBjb3Vs
ZCBiZSBwdXNoZWQNCj4gb3V0IGZyb20gY2FjaGUgaWYgVk0gZGVjaWRlLg0KPiANCj4gVGhpcyBj
YW4gc29sdmVkIGJ5IG1vdmluZyBhICJ3YXRjaGVyIiB0byBhIHNlcGFyYXRlIChkYWVtb24pIHBy
b2Nlc3MsIGFuZA0KPiBtbG9ja2luZyBpdC4gV2UgZG8gdGhpcyBpbiB1bG1rZC4NCg0KUmlnaHQu
IEl0IGJ1dCBpdCBoYXMgZHJhd2JhY2tzIGFzIHdlbGwgZS5nLiBlbnN1cmUgdGhhdCBkYWVtb24g
c2NoZWR1bGVkIHByb3Blcmx5IGFuZCBwcm9wYWdhdGUgcmVhY3Rpb24gZGVjaXNpb24gb3V0c2lk
ZSB1bG1rZC4NCkFsc28gSSB1bmRlcnN0YW5kIHlvdXIgc3RhdGVtZW50IGFib3V0ICJ3YXRjaGVy
IiBhcyBwcm9iYWJseSB5b3UgdXNlIG9uZSB0aW1lciBmb3IgZGFlbW9uLiANCkJ0dywgaW4gbXkg
dmFyaWFudCAobWVtbm90aWZ5LmMpIEkgdXNlZCBvbmx5IG9uZSB0aW1lciwgaXQgaXMgZW5vdWdo
Lg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F99B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:31:47 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id l83so5702445ybl.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:31:47 -0800 (PST)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730056.outbound.protection.outlook.com. [40.107.73.56])
        by mx.google.com with ESMTPS id m129si46092114ywb.139.2019.01.10.07.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 07:31:46 -0800 (PST)
From: "StDenis, Tom" <Tom.StDenis@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Thu, 10 Jan 2019 15:31:42 +0000
Message-ID: <5bb81bc0-1313-7f33-7ed6-6424454300ad@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com>
 <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <CABXGCsN4NwYG4UeJ9a-P_8cEd1qg_sC24z3L3Ek9Wn0JttkZ=g@mail.gmail.com>
In-Reply-To: 
 <CABXGCsN4NwYG4UeJ9a-P_8cEd1qg_sC24z3L3Ek9Wn0JttkZ=g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A771F76D90A4F048A8EC95D6807DDE11@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>

SGkgTWlrZSwNCg0KVGhpcyBtaWdodCBiZSBhbiBpc3N1ZSBiZXR0ZXIgc3VpdGVkIGZvciBvdXIg
bGx2bSB0ZWFtIHNpbmNlIHVtciBqdXN0IA0KdXNlcyBsbHZtLWRldiB0byBhY2Nlc3MgdGhlIGRp
YXNzZW1ibHkgY29kZS4NCg0KSSdsbCBtYWtlIHN1cmUgdGhlIGtleSBmb2xrIGFyZSBhd2FyZS4N
Cg0KQ2hlZXJzLA0KVG9tDQoNCg0KT24gMjAxOS0wMS0xMCAxMDoyMiBhLm0uLCBNaWtoYWlsIEdh
dnJpbG92IHdyb3RlOg0KPiBPbiBUaHUsIDEwIEphbiAyMDE5IGF0IDAwOjM2LCBNaWtoYWlsIEdh
dnJpbG92DQo+IDxtaWtoYWlsLnYuZ2F2cmlsb3ZAZ21haWwuY29tPiB3cm90ZToNCj4+DQo+PiBB
bGwgbmV3IG9uZSBsb2dzIGF0dGFjaGVkIGhlcmUuDQo+Pg0KPj4gVGhhbmtzLg0KPj4NCj4+IFAu
Uy4gVGhpcyB0aW1lIEkgaGFkIHRvIHRlcm1pbmF0ZSBjb21tYW5kIGAuL3VtciAtTyB2ZXJib3Nl
LGZvbGxvdyAtUg0KPj4gZ2Z4Wy5dID4gZ2Z4LmxvZyAyPiYxYCBjYXVzZSBpdCB0cmllZCB0byB3
cml0ZSBsb2cgaW5maW5pdGVseS4NCj4+IEkgYWxzbyBoYWQgdG8gdGVybWluYXRlIGNvbW1hbmQg
YC4vdW1yIC1PIHZlcmJvc2UsZm9sbG93IC1SIGdmeFsuXSA+DQo+PiBnZngubG9nIDI+JjFgIGNh
dXNlIGl0IHN0dWNrIGZvciBhIGxvbmcgdGltZS4NCj4+DQo+Pg0KPiANCj4gSXQgYmVjYW1lIGNs
ZWFyIHdoeSB1bXIgc3R1Y2sgYXQgdGhlIGdmeCBkdW1wLiBJIHJhbiB1bXIgdW5kZXIgZ2RiIGFu
ZA0KPiBJIGdvdCAgYSBzZWdmYXVsdCBhdCBhIG1vbWVudCB3aGVuIHVtciB3YXMgc3R1Y2sgZWFy
bGllci4NCj4gVG9tLCBhcmUgeW91IGhlcmU/IENhbiB5b3UgbG9vayBhdHRhY2hlZCBiYWNrdHJh
Y2U/DQo+IA0KPiANCj4gLS0NCj4gQmVzdCBSZWdhcmRzLA0KPiBNaWtlIEdhdnJpbG92Lg0KPiAN
Cg0K

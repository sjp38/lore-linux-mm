Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 012D9800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:26:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r6so3790333pfk.9
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:26:36 -0800 (PST)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id x10si3308876pff.290.2018.01.24.11.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 11:26:35 -0800 (PST)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [LSF/MM TOPIC] Patch Submission process and Handling Internal
 Conflict
Date: Wed, 24 Jan 2018 19:26:20 +0000
Message-ID: <1516821978.3987.8.camel@wdc.com>
References: <1516820744.3073.30.camel@HansenPartnership.com>
In-Reply-To: <1516820744.3073.30.camel@HansenPartnership.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1993780F844C1448B784847B6C3B1795@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

T24gV2VkLCAyMDE4LTAxLTI0IGF0IDExOjA1IC0wODAwLCBKYW1lcyBCb3R0b21sZXkgd3JvdGU6
DQo+IDIuIEhhbmRsaW5nIEludGVybmFsIENvbmZsaWN0DQo+IA0KPiBNeSBvYnNlcnZhdGlvbiBo
ZXJlIGlzIHRoYXQgYWN0dWFsbHkgbW9zdCBjb25mbGljdCBpcyBnZW5lcmF0ZWQgYnkgdGhlDQo+
IHJldmlldyBwcm9jZXNzIChJIGtub3csIGlmIHdlIGluY3JlYXNlIHJldmlld3MgYXMgSSBwcm9w
b3NlIGluIDEuIHdlJ2xsDQo+IGluY3JlYXNlIGNvbmZsaWN0IG9uIHRoZSBsaXN0cyBvbiB0aGUg
YmFzaXMgb2YgdGhpcyBvYnNlcnZhdGlvbiksIHNvDQo+IEkndmUgYmVlbiB0aGlua2luZyBhYm91
dCB3YXlzIHRvIGRlLWVzY2FsYXRlIGl0LiAgVGhlIHByaW5jaXBsZSBpc3N1ZQ0KPiBpcyB0aGF0
IGEgcmV2aWV3IHdoaWNoIGRvZXNuJ3QganVzdCBzYXkgdGhlIHBhdGNoIGlzIGZpbmUgKG9yIGZp
bmUNCj4gZXhjZXB0IGZvciBuaXRwaWNrcykgY2FuIGJlIHRha2VuIGFzIGNyaXRpY2lzbSBhbmQg
Y3JpdGljaXNtIGlzIG9mdGVuDQo+IHByb2Nlc3NlZCBwZXJzb25hbGx5LiAgVGhlIHdheSB5b3Ug
cGhyYXNlIGNyaXRpY2lzbSBjYW4gaGF2ZSBhIGdyZWF0DQo+IGJlYXJpbmcgb24gdGhlIGFtb3Vu
dCBvZiBwZXJzb25hbCBpbnN1bHQgdGFrZW4gYnkgdGhlIG90aGVyIHBhcnR5Lg0KPiAgQ29ybnkg
YXMgaXQgc291bmRzLCB0aGUgMGRheSBib3QgcmVzcG9uc2UgIkhpIFosIEkgbG92ZSB5b3VyIHBh
dGNoIQ0KPiBQZXJoYXBzIHNvbWV0aGluZyB0byBpbXByb3ZlOiIgaXMgc3BlY2lmaWNhbGx5IHRh
cmdldHRlZCBhdCB0aGlzDQo+IHByb2JsZW0gYW5kIHNlZW1zIGFjdHVhbGx5IHRvIHdvcmsuICBJ
IHRoaW5rIHdlIGNvdWxkIGFsbCBiZW5lZml0IGZyb20NCj4gZGlzY3Vzc2luZyBob3cgdG8gZ2l2
ZSBhbmQgcmVjZWl2ZSBjcml0aWNpc20gaW4gdGhlIGZvcm0gb2YgcGF0Y2gNCj4gcmV2aWV3cyBy
ZXNwb25zaWJseSwgZXNwZWNpYWxseSBhcyBub3QgZXZlcnlvbmUncyBuYXRpdmUgbGFuZ3VhZ2Ug
aW4NCj4gRW5nbGlzaCBhbmQgY2VydGFpbiBjb21tb24gbGluZ3Vpc3RpYyBwaHJhc2luZ3MgaW4g
b3RoZXIgbGFuZ3VhZ2VzIGNhbg0KPiBjb21lIG9mZiBhcyBydWRlIHdoZW4gZGlyZWN0bHkgdHJh
bnNsYXRlZCB0byBFbmdsaXNoIChSdXNzaWFuIHNwcmluZ3MNCj4gaW1tZWRpYXRlbHkgdG8gbWlu
ZCBmb3Igc29tZSByZWFzb24gaGVyZSkuICBBbHNvIE5vdGUsIEkgdGhpbmsgZml4aW5nDQo+IHRo
ZSByZXZpZXcgcHJvYmxlbSB3b3VsZCBzb2x2ZSBtb3N0IG9mIHRoZSBpc3N1ZXMsIHNvIEknbSBu
b3QgcHJvcG9zaW5nDQo+IGFueXRoaW5nIG1vcmUgZm9ybWFsIGxpa2UgdGhlIGNvZGUgb2YgY29u
ZmxpY3Qgc3R1ZmYgaW4gdGhlIG1haW4NCj4ga2VybmVsLg0KPiANCj4gV2UgY291bGQgbHVtcCBi
b3RoIG9mIHRoZXNlIHVuZGVyIGEgc2luZ2xlICJDb21tdW5pdHkgRGlzY3Vzc2lvbiIgdG9waWMN
Cj4gaWYgdGhlIG9yZ2FuaXplcnMgcHJlZmVyIC4uLiBlc3BlY2lhbGx5IGlmIGFueW9uZSBoYXMg
YW55IG90aGVyDQo+IGNvbW11bml0eSB0eXBlIGlzc3VlcyB0aGV5J2QgbGlrZSB0byBicmluZyB1
cC4NCg0KSGVsbG8gSmFtZXMsDQoNCkhvdyBhYm91dCBkaXNjdXNzaW5nIHRoZSBmb2xsb3dpbmcg
dHdvIGFkZGl0aW9uYWwgdG9waWNzIGR1cmluZyB0aGUgc2FtZSBvcg0KYW5vdGhlciBzZXNzaW9u
Og0KKiBXZSBhbGwgd2FudCBhIGNvbmNlbnN1cyBhYm91dCB0aGUgY29kZSBhbmQgdGhlIGFsZ29y
aXRobXMgaW4gdGhlIExpbnV4DQogIGtlcm5lbC4gSG93ZXZlciwgc29tZSBjb250cmlidXRvcnMg
YXJlIG5vdCBpbnRlcmVzdGVkIGluIHRyeWluZyB0byBzdHJpdmUNCiAgdG93YXJkcyBhIGNvbmNl
bnN1cy4gSWYgc29tZSBjb250cmlidXRvcnMgZS5nLiByZWNlaXZlIGEgcmVxdWVzdCB0byByZXdv
cmsNCiAgdGhlaXIgcGF0Y2hlcywgaWYgdGhleSBkb24ndCBsaWtlIHRoYXQgcmVxdWVzdCBhbmQg
aWYgdGhlIHJldmlld2VyIGlzDQogIHdvcmtpbmcgZm9yIHRoZSBzYW1lIGVtcGxveWVyIHNvbWV0
aW1lcyB0aGV5IHRyeSB0byB1c2UgdGhlIGNvcnBvcmF0ZQ0KICBoaWVyYXJjaHkgdG8gbWFrZSB0
aGUgcmV2aWV3ZXIgc2h1dCB1cC4gSSB0aGluayB0aGlzIGlzIGJlaGF2aW9yIHRoYXQgd29ya3MN
CiAgYWdhaW5zdCB0aGUgbG9uZy10ZXJtIGludGVyZXN0cyBvZiB0aGUgTGludXgga2VybmVsLg0K
KiBTb21lIG90aGVyIGNvbnRyaWJ1dG9ycyBhcmUgbm90IGludGVyZXN0ZWQgaW4gYWNoaWV2aW5n
IGEgY29uc2Vuc3VzIGFuZCBkbw0KICBub3QgYXR0ZW1wdCB0byBhZGRyZXNzIHJldmlld2VyIGZl
ZWRiYWNrIGJ1dCBpbnN0ZWFkIGtlZXAgYXJndWluZyBvciBkbyB3aGF0DQogIHRoZXkgY2FuIHRv
IGluc3VsdCB0aGUgcmV2aWV3ZXIuDQoNClRoYW5rcywNCg0KQmFydC4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

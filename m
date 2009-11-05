Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2D88C6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 01:47:18 -0500 (EST)
From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Thu, 5 Nov 2009 14:44:51 +0800
Subject: RE: [PATCH 02/11] Add "handle page fault" PV helper.
Message-ID: <0A882F4D99BBF6449D58E61AAFD7EDD6339E7098@pdsmsx502.ccr.corp.intel.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-3-git-send-email-gleb@redhat.com>
 <20091102092214.GB8933@elte.hu> <4AEF2D0A.4070807@redhat.com>
 <4AEF3419.1050200@redhat.com> <4AEF6CC3.4000508@redhat.com>
 <4AEFB823.4040607@redhat.com>
In-Reply-To: <4AEFB823.4040607@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Gleb Natapov <gleb@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

PkZyb206IEF2aSBLaXZpdHkNCj5TZW50OiAyMDA5xOoxMdTCM8jVIDEyOjU3DQo+DQo+T24gMTEv
MDMvMjAwOSAwMTozNSBBTSwgUmlrIHZhbiBSaWVsIHdyb3RlOg0KPj4+IFdlIGNhbid0IGFkZCBh
biBleGNlcHRpb24gdmVjdG9yIHNpbmNlIGFsbCB0aGUgZXhpc3RpbmcgDQo+b25lcyBhcmUgZWl0
aGVyDQo+Pj4gdGFrZW4gb3IgcmVzZXJ2ZWQuDQo+Pg0KPj4NCj4+IEkgYmVsaWV2ZSBzb21lIGFy
ZSByZXNlcnZlZCBmb3Igb3BlcmF0aW5nIHN5c3RlbSB1c2UuDQo+DQo+VGFibGUgNi0xIHNheXM6
DQo+DQo+ICAgOSB8ICB8IENvcHJvY2Vzc29yIFNlZ21lbnQgT3ZlcnJ1biAocmVzZXJ2ZWQpICB8
ICBGYXVsdCB8ICBObyAgfCANCj5GbG9hdGluZy1wb2ludCBpbnN0cnVjdGlvbi4yDQo+ICAgMTUg
fCAgoaogfCAgKEludGVsIHJlc2VydmVkLiBEbyBub3QgdXNlLikgfCAgIHwgTm8gfA0KPiAgIDIw
LTMxIHwgIKGqIHwgSW50ZWwgcmVzZXJ2ZWQuIERvIG5vdCB1c2UuICB8DQo+ICAgMzItMjU1IHwg
IKGqICB8IFVzZXIgRGVmaW5lZCAoTm9uLXJlc2VydmVkKSBJbnRlcnJ1cHRzIHwgIEludGVycnVw
dCAgDQo+fCAgIHwgRXh0ZXJuYWwgaW50ZXJydXB0IG9yIElOVCBuIGluc3RydWN0aW9uLg0KPg0K
PlNvIHdlIGNhbiBvbmx5IHVzZSAzMi0yNTUsIGJ1dCB0aGVzZSBhcmUgbm90IGZhdWx0LWxpa2Ug
DQo+ZXhjZXB0aW9ucyB0aGF0IA0KPmNhbiBiZSBkZWxpdmVyZWQgd2l0aCBpbnRlcnJ1cHRzIGRp
c2FibGVkLg0KPg0KDQp3b3VsZCB5b3UgcmVhbGx5IHdhbnQgdG8gaW5qZWN0IGEgZmF1bHQtbGlr
ZSBleGNlcHRpb24gaGVyZT8gRmF1bHQNCmlzIGFyY2hpdHVyYWxseSBzeW5jaHJvbm91cyBldmVu
dCB3aGlsZSBoZXJlIGFwZiBpcyBtb3JlIGxpa2UgYW4gDQphc3luY2hyb25vdXMgaW50ZXJydXB0
IGFzIGl0J3Mgbm90IGNhdXNlZCBieSBndWVzdCBpdHNlbGYuIElmIA0KZ3Vlc3QgaXMgd2l0aCBp
bnRlcnJ1cHQgZGlzYWJsZWQsIHByZWVtcHRpb24gd29uJ3QgaGFwcGVuIGFuZCANCmFwZiBwYXRo
IGp1c3QgZW5kcyB1cCAid2FpdCBmb3IgcGFnZSIgaHlwZXJjYWxsIHRvIHdhc3RlIGN5Y2xlcy4N
Cg0KVGhhbmtzLA0KS2V2aW4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

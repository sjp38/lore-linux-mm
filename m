Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 136656B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:22:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r6so6790352pfj.14
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:22:00 -0700 (PDT)
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id m5si6270465pll.195.2017.10.19.13.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 13:21:58 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Date: Thu, 19 Oct 2017 20:21:56 +0000
Message-ID: <1508444515.2429.55.camel@wdc.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
	  <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
	  <1508425527.2429.11.camel@wdc.com>
	  <alpine.DEB.2.20.1710191718260.1971@nanos>
	 <1508428021.2429.22.camel@wdc.com>
	 <alpine.DEB.2.20.1710192021480.2054@nanos>
	 <alpine.DEB.2.20.1710192107000.2054@nanos>
In-Reply-To: <alpine.DEB.2.20.1710192107000.2054@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <040F5F1146986E43BE65AD6C9E9B4C7C@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

T24gVGh1LCAyMDE3LTEwLTE5IGF0IDIxOjEyICswMjAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IEFuZCBqdXN0IGZvciB0aGUgcmVjb3JkLCBJIHdhc3RlZCBlbm91Z2ggb2YgbXkgdGltZSBh
bHJlYWR5IHRvIGRlY29kZSAnY2FuDQo+IG5vdCBoYXBwZW4nIGRlYWQgbG9ja3Mgd2hlcmUgY29t
cGxldGlvbnMgb3Igb3RoZXIgd2FpdCBwcmltaXRpdmVzIGhhdmUgYmVlbg0KPiBpbnZvbHZlZC4g
SSByYXRoZXIgc3BlbmQgdGltZSBhbm5vdGF0aW5nIHN0dWZmIGFmdGVyIGFuYWx5emluZyBpdCBw
cm9wZXINCj4gdGhhbiBjaGFzaW5nIGhhcHBlbnMgb25jZSBpbiBhIGJsdWUgbW9vbiBsb2NrdXBz
IHdoaWNoIGFyZSBjb21wbGV0ZWx5DQo+IHVuZXhwbGFpbmFibGUuDQo+IA0KPiBUaGF0J3Mgd2h5
IGxvY2tkZXAgZXhpc3RzIGluIHRoZSBmaXJzdCBwbGFjZS4gSW5nbywgU3RldmVuLCBteXNlbGYg
YW5kDQo+IG90aGVycyBzcGVudCBhbiBpbnNhbmUgYW1vdW50IG9mIHRpbWUgdG8gZml4IGxvY2tp
bmcgYnVncyBhbGwgb3ZlciB0aGUgdHJlZQ0KPiB3aGVuIHdlIHN0YXJ0ZWQgdGhlIHByZWVtcHQg
UlQgd29yay4gTG9ja2RlcCB3YXMgYSByZXNjdWUgYmVjYXVzZSBpdCBmb3JjZWQNCj4gcGVvcGxl
IHRvIGxvb2sgYXQgdGhlaXIgb3duIGNyYXAgYW5kIGlmIGl0IHdhcyAxMDAlIGNsZWFyIHRoYXQg
bG9ja2RlcA0KPiB0cmlwcGVkIGEgZmFsc2UgcG9zaXRpdmUgZWl0aGVyIGxvY2tkZXAgd2FzIGZp
eGVkIG9yIHRoZSBjb2RlIGluIHF1ZXN0aW9uDQo+IGFubm90YXRlZCwgd2hpY2ggaXMgYSBnb29k
IHRoaW5nIGJlY2F1c2UgdGhhdCdzIGRvY3VtZW50YXRpb24gYXQgdGhlIHNhbWUNCj4gdGltZS4N
Cg0KSGVsbG8gVGhvbWFzLA0KDQpJbiBjYXNlIGl0IHdvdWxkbid0IGJlIGNsZWFyLCB5b3VyIHdv
cmsgYW5kIHRoZSB3b3JrIG9mIG90aGVycyBvbiBsb2NrZGVwDQphbmQgcHJlZW1wdC1ydCBpcyBo
aWdobHkgYXBwcmVjaWF0ZWQuIFNvcnJ5IHRoYXQgSSBtaXNzZWQgdGhlIGRpc2N1c3Npb24NCmFi
b3V0IHRoZSBjcm9zcy1yZWxlYXNlIGZ1bmN0aW9uYWxpdHkgd2hlbiBpdCB3ZW50IHVwc3RyZWFt
LiBJIGhhdmUgc2V2ZXJhbA0KcXVlc3Rpb25zIGFib3V0IHRoYXQgZnVuY3Rpb25hbGl0eToNCiog
SG93IG1hbnkgbG9jayBpbnZlcnNpb24gcHJvYmxlbXMgaGF2ZSBiZWVuIGZvdW5kIHNvIGZhciB0
aGFua3MgdG8gdGhlDQogIGNyb3NzLXJlbGVhc2UgY2hlY2tpbmc/IEhvdyBtYW55IGZhbHNlIHBv
c2l0aXZlcyBoYXZlIHRoZSBjcm9zcy1yZWxlYXNlDQogIGNoZWNrcyB0cmlnZ2VyZWQgc28gZmFy
PyBEb2VzIHRoZSBudW1iZXIgb2YgcmVhbCBpc3N1ZXMgdGhhdCBoYXMgYmVlbg0KICBmb3VuZCBv
dXR3ZWlnaCB0aGUgZWZmb3J0IHNwZW50IG9uIHN1cHByZXNzaW5nIGZhbHNlIHBvc2l0aXZlcz8N
CiogV2hhdCBhbHRlcm5hdGl2ZXMgaGF2ZSBiZWVuIGNvbnNpZGVyZWQgb3RoZXIgdGhhbiBlbmFi
bGluZyBjcm9zcy1yZWxlYXNlDQogIGNoZWNraW5nIGZvciBhbGwgbG9ja2luZyBvYmplY3RzIHRo
YXQgc3VwcG9ydCByZWxlYXNpbmcgZnJvbSB0aGUgY29udGV4dA0KICBvZiBhbm90aGVyIHRhc2sg
dGhhbiB0aGUgY29udGV4dCBmcm9tIHdoaWNoIHRoZSBsb2NrIHdhcyBvYnRhaW5lZD8gSGFzIGl0
DQogIGUuZy4gYmVlbiBjb25zaWRlcmVkIHRvIGludHJvZHVjZSB0d28gdmVyc2lvbnMgb2YgdGhl
IGxvY2sgb2JqZWN0cyB0aGF0DQogIHN1cHBvcnQgY3Jvc3MtcmVsZWFzZXMgLSBvbmUgdmVyc2lv
biBmb3Igd2hpY2ggbG9jayBpbnZlcnNpb24gY2hlY2tpbmcgaXMNCiAgYWx3YXlzIGVuYWJsZWQg
YW5kIGFub3RoZXIgdmVyc2lvbiBmb3Igd2hpY2ggbG9jayBpbnZlcnNpb24gY2hlY2tpbmcgaXMN
CiAgYWx3YXlzIGRpc2FibGVkPw0KKiBIb3cgbXVjaCByZXZpZXcgaGFzIHRoZSBEb2N1bWVudGF0
aW9uL2xvY2tpbmcvY3Jvc3NyZWxlYXNlLnR4dCByZWNlaXZlZA0KICBiZWZvcmUgaXQgd2VudCB1
cHN0cmVhbT8gQXQgbGVhc3QgdG8gbWUgdGhhdCBkb2N1bWVudCBzZWVtcyBtdWNoIGhhcmRlcg0K
ICB0byByZWFkIHRoYW4gb3RoZXIga2VybmVsIGRvY3VtZW50YXRpb24gZHVlIHRvIHdlaXJkIHVz
ZSBvZiB0aGUgRW5nbGlzaA0KICBncmFtbWFyLg0KDQpUaGFua3MsDQoNCkJhcnQu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

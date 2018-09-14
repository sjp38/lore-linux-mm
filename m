Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7C58E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:36:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g5-v6so4508511pgq.5
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:36:30 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id 91-v6si7476379ply.405.2018.09.14.13.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:36:29 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/5] ioremap: Rework pXd_free_pYd_page() API
Date: Fri, 14 Sep 2018 20:36:24 +0000
Message-ID: <71baefb8e0838fba89ee06262bbb2456e9091c7a.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-2-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536747974-25875-2-git-send-email-will.deacon@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FDC81075871C414DBA737385CD30F171@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gV2VkLCAyMDE4LTA5LTEyIGF0IDExOjI2ICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
VGhlIHJlY2VudGx5IG1lcmdlZCBBUEkgZm9yIGVuc3VyaW5nIGJyZWFrLWJlZm9yZS1tYWtlIG9u
IHBhZ2UtdGFibGUNCj4gZW50cmllcyB3aGVuIGluc3RhbGxpbmcgaHVnZSBtYXBwaW5ncyBpbiB0
aGUgdm1hbGxvYy9pb3JlbWFwIHJlZ2lvbiBpcw0KPiBmYWlybHkgY291bnRlci1pbnR1aXRpdmUs
IHJlc3VsdGluZyBpbiB0aGUgYXJjaCBmcmVlaW5nIGZ1bmN0aW9ucw0KPiAoZS5nLiBwbWRfZnJl
ZV9wdGVfcGFnZSgpKSBiZWluZyBjYWxsZWQgZXZlbiBvbiBlbnRyaWVzIHRoYXQgYXJlbid0DQo+
IHByZXNlbnQuIFRoaXMgcmVzdWx0ZWQgaW4gYSBtaW5vciBidWcgaW4gdGhlIGFybTY0IGltcGxl
bWVudGF0aW9uLCBnaXZpbmcNCj4gcmlzZSB0byBzcHVyaW91cyBWTV9XQVJOIG1lc3NhZ2VzLg0K
PiANCj4gVGhpcyBwYXRjaCBtb3ZlcyB0aGUgcFhkX3ByZXNlbnQoKSBjaGVja3Mgb3V0IGludG8g
dGhlIGNvcmUgY29kZSwNCj4gcmVmYWN0b3JpbmcgdGhlIGNhbGxzaXRlcyBhdCB0aGUgc2FtZSB0
aW1lIHNvIHRoYXQgd2UgYXZvaWQgdGhlIGNvbXBsZXgNCj4gY29uanVuY3Rpb25zIHdoZW4gZGV0
ZXJtaW5pbmcgd2hldGhlciBvciBub3Qgd2UgY2FuIHB1dCBkb3duIGEgaHVnZQ0KPiBtYXBwaW5n
Lg0KPiANCj4gQ2M6IENoaW50YW4gUGFuZHlhIDxjcGFuZHlhQGNvZGVhdXJvcmEub3JnPg0KPiBD
YzogVG9zaGkgS2FuaSA8dG9zaGkua2FuaUBocGUuY29tPg0KPiBDYzogVGhvbWFzIEdsZWl4bmVy
IDx0Z2x4QGxpbnV0cm9uaXguZGU+DQo+IENjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNv
bT4NCj4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+IFN1
Z2dlc3RlZC1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3Jn
Pg0KPiBTaWduZWQtb2ZmLWJ5OiBXaWxsIERlYWNvbiA8d2lsbC5kZWFjb25AYXJtLmNvbT4NCg0K
WWVzLCB0aGlzIGxvb2tzIG5pY2VyLg0KDQpSZXZpZXdlZC1ieTogVG9zaGkgS2FuaSA8dG9zaGku
a2FuaUBocGUuY29tPg0KDQpUaGFua3MsDQotVG9zaGkNCg==

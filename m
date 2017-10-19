Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4275D6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:05:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s75so7034384pgs.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:05:55 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id d125si5864037pgc.444.2017.10.19.08.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 08:05:53 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Date: Thu, 19 Oct 2017 15:05:28 +0000
Message-ID: <1508425527.2429.11.camel@wdc.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
	 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B65C9874EB6996468254414660B41357@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>

T24gVGh1LCAyMDE3LTEwLTE5IGF0IDE0OjU1ICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gTm93IHRoZSBwZXJmb3JtYW5jZSByZWdyZXNzaW9uIHdhcyBmaXhlZCwgcmUtZW5hYmxlDQo+
IENPTkZJR19MT0NLREVQX0NST1NTUkVMRUFTRSBhbmQgQ09ORklHX0xPQ0tERVBfQ09NUExFVElP
TlMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBCeXVuZ2NodWwgUGFyayA8Ynl1bmdjaHVsLnBhcmtA
bGdlLmNvbT4NCj4gLS0tDQo+ICBsaWIvS2NvbmZpZy5kZWJ1ZyB8IDQgKystLQ0KPiAgMSBmaWxl
IGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1n
aXQgYS9saWIvS2NvbmZpZy5kZWJ1ZyBiL2xpYi9LY29uZmlnLmRlYnVnDQo+IGluZGV4IDkwZWE3
ODQuLmZlOGZjZWIgMTAwNjQ0DQo+IC0tLSBhL2xpYi9LY29uZmlnLmRlYnVnDQo+ICsrKyBiL2xp
Yi9LY29uZmlnLmRlYnVnDQo+IEBAIC0xMTM4LDggKzExMzgsOCBAQCBjb25maWcgUFJPVkVfTE9D
S0lORw0KPiAgCXNlbGVjdCBERUJVR19NVVRFWEVTDQo+ICAJc2VsZWN0IERFQlVHX1JUX01VVEVY
RVMgaWYgUlRfTVVURVhFUw0KPiAgCXNlbGVjdCBERUJVR19MT0NLX0FMTE9DDQo+IC0Jc2VsZWN0
IExPQ0tERVBfQ1JPU1NSRUxFQVNFIGlmIEJST0tFTg0KPiAtCXNlbGVjdCBMT0NLREVQX0NPTVBM
RVRJT05TIGlmIEJST0tFTg0KPiArCXNlbGVjdCBMT0NLREVQX0NST1NTUkVMRUFTRQ0KPiArCXNl
bGVjdCBMT0NLREVQX0NPTVBMRVRJT05TDQo+ICAJc2VsZWN0IFRSQUNFX0lSUUZMQUdTDQo+ICAJ
ZGVmYXVsdCBuDQo+ICAJaGVscA0KDQpJIGRvIG5vdCBhZ3JlZSB3aXRoIHRoaXMgcGF0Y2guIEFs
dGhvdWdoIHRoZSB0cmFkaXRpb25hbCBsb2NrIHZhbGlkYXRpb24NCmNvZGUgY2FuIGJlIHByb3Zl
biBub3QgdG8gcHJvZHVjZSBmYWxzZSBwb3NpdGl2ZXMsIHRoYXQgaXMgbm90IHRoZSBjYXNlIGZv
cg0KdGhlIGNyb3NzLXJlbGVhc2UgY2hlY2tzLiBUaGVzZSBjaGVja3MgYXJlIHByb25lIHRvIHBy
b2R1Y2UgZmFsc2UgcG9zaXRpdmVzLg0KTWFueSBrZXJuZWwgZGV2ZWxvcGVycywgaW5jbHVkaW5n
IG15c2VsZiwgYXJlIG5vdCBpbnRlcmVzdGVkIGluIHNwZW5kaW5nDQp0aW1lIG9uIGFuYWx5emlu
ZyBmYWxzZSBwb3NpdGl2ZSBkZWFkbG9jayByZXBvcnRzLiBTbyBJIHRoaW5rIHRoYXQgaXQgaXMN
Cndyb25nIHRvIGVuYWJsZSBjcm9zcy1yZWxlYXNlIGNoZWNraW5nIHVuY29uZGl0aW9uYWxseSBp
ZiBQUk9WRV9MT0NLSU5HIGhhcw0KYmVlbiBlbmFibGVkLiBXaGF0IEkgdGhpbmsgdGhhdCBzaG91
bGQgaGFwcGVuIGlzIHRoYXQgZWl0aGVyIHRoZSBjcm9zcy0NCnJlbGVhc2UgY2hlY2tpbmcgY29k
ZSBpcyByZW1vdmVkIGZyb20gdGhlIGtlcm5lbCBvciB0aGF0DQpMT0NLREVQX0NST1NTUkVMRUFT
RSBiZWNvbWVzIGEgbmV3IGtlcm5lbCBjb25maWd1cmF0aW9uIG9wdGlvbi4gVGhhdCB3aWxsDQpn
aXZlIGtlcm5lbCBkZXZlbG9wZXJzIHdobyBjaG9vc2UgdG8gZW5hYmxlIFBST1ZFX0xPQ0tJTkcg
dGhlIGZyZWVkb20gdG8NCmRlY2lkZSB3aGV0aGVyIG9yIG5vdCB0byBlbmFibGUgTE9DS0RFUF9D
Uk9TU1JFTEVBU0UuDQoNCkJhcnQu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

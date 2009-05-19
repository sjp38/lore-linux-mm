Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E48A6B005D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 03:16:27 -0400 (EDT)
From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Tue, 19 May 2009 15:15:44 +0800
Subject: RE: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <4D05DB80B95B23498C72C700BD6C2E0B2EF6E465@pdsmsx502.ccr.corp.intel.com>
References: <20090519125744.4EC3.A69D9226@jp.fujitsu.com>
 <4D05DB80B95B23498C72C700BD6C2E0B2EF6E313@pdsmsx502.ccr.corp.intel.com>
 <20090519141050.4ED5.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090519141050.4ED5.A69D9226@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Pj4tLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPj5Gcm9tOiBLT1NBS0kgTW90b2hpcm8gW21h
aWx0bzprb3Nha2kubW90b2hpcm9AanAuZnVqaXRzdS5jb21dDQo+PlNlbnQ6IDIwMDnE6jXUwjE5
yNUgMTU6MTANCj4+VG86IFpoYW5nLCBZYW5taW4NCj4+Q2M6IGtvc2FraS5tb3RvaGlyb0BqcC5m
dWppdHN1LmNvbTsgV3UsIEZlbmdndWFuZzsgTEtNTDsgbGludXgtbW07IEFuZHJldw0KPj5Nb3J0
b247IFJpayB2YW4gUmllbDsgQ2hyaXN0b3BoIExhbWV0ZXINCj4+U3ViamVjdDogUmU6IFtQQVRD
SCA0LzRdIHpvbmVfcmVjbGFpbV9tb2RlIGlzIGFsd2F5cyAwIGJ5IGRlZmF1bHQNCj4+DQo+Pkhp
DQo+Pg0KPj4+ID4+PiA+Pk5vdywgaXQgd2FzIGJyZWFrZWQuIFdoYXQgc2hvdWxkIHdlIGRvPw0K
Pj4+ID4+PiA+Pllhbm1pbiwgV2Uga25vdyA5OSUgbGludXggcGVvcGxlIHVzZSBpbnRlbCBjcHUg
YW5kIHlvdSBhcmUgb25lIG9mDQo+Pj4gPj4+ID4+bW9zdCBoYXJkIHJlcGVhdGVkIHRlc3RpbmcN
Cj4+PiA+Pj4gW1lNXSBJdCdzIHZlcnkgZWFzeSB0byByZXByb2R1Y2UgdGhlbSBvbiBteSBtYWNo
aW5lcy4gOikgU29tZXRpbWVzLCBiZWNhdXNlDQo+Pj4gPj50aGUNCj4+PiA+Pj4gaXNzdWVzIG9u
bHkgZXhpc3Qgb24gbWFjaGluZXMgd2l0aCBsb3RzIG9mIGNwdSB3aGlsZSBvdGhlciBjb21tdW5p
dHkNCj4+PiA+PmRldmVsb3BlcnMNCj4+PiA+Pj4gaGF2ZSBubyBzdWNoIGVudmlyb25tZW50cy4N
Cj4+PiA+Pj4NCj4+PiA+Pj4NCj4+PiA+Pj4gIGd1eSBpbiBsa21sIGFuZCB5b3UgaGF2ZSBtdWNo
IHRlc3QuDQo+Pj4gPj4+ID4+TWF5IEkgYXNrIHlvdXIgdGVzdGVkIG1hY2hpbmUgYW5kIGJlbmNo
bWFyaz8NCj4+PiA+Pj4gW1lNXSBVc3VhbGx5IEkgc3RhcnRlZCBsb3RzIG9mIGJlbmNobWFyayB0
ZXN0aW5nIGFnYWluc3QgdGhlIGxhdGVzdA0KPj4+ID4+DQo+Pj4gPj5ZZWFoLCB0aGF0J3Mgb2su
IEkgYW5kIGNyaXN0b3BoIGhhdmUuIE15IHdvcnJpZXMgaXMgbXkgdW5rbm93biB3b3JrbG9hZA0K
Pj5iZWNvbWUNCj4+PiA+PnJlZ3Jlc3Npb24uDQo+Pj4gPj5zbywgTWF5IEkgYXNzdW1lIHlvdSBy
dW4geW91ciBiZW5jaG1hcmsgYm90aCB6b25yZSByZWNsYWltIDAgYW5kIDEgYW5kIHlvdQ0KPj4+
ID4+aGF2ZW4ndCBzZWVuIHJlZ3Jlc3Npb24gYnkgbm9uLXpvbmUgcmVjbGFpbSBtb2RlPw0KPj4+
IFtZTV0gd2hhdCBpcyBub24tem9uZSByZWNsYWltIG1vZGU/IFdoZW4gem9uZV9yZWNsYWltX21v
ZGU9MD8NCj4+PiBJIGRpZG4ndCBkbyB0aGF0IGludGVudGlvbmFsbHkuIEN1cnJlbnRseSBJIGp1
c3QgbWFrZSBzdXJlIEZJTyBoYXMgYSBiaWcgZHJvcA0KPj4+ICB3aGVuIHpvbmVfcmVjbGFpbV9t
b2RlPTEuIEkgbWlnaHQgdGVzdCBpdCB3aXRoIG90aGVyIGJlbmNobWFya3Mgb24gMiBOZWhhbGVt
DQo+Pm1hY2hpbmVzLg0KPj4NCg0KPj5NYXkgSSBhc2sgd2hhdCBpcyBGSU8/DQo+PkZpbGUgSU8/
DQpbWU1dIGZpbyBpcyBhIHRvb2wgdG8gdGVzdCBJL08uIEplbnMgQXhib2UgaXMgdGhlIGF1dGhv
ci4NCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

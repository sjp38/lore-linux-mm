Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id CD1296B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:22:44 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Thu, 1 Aug 2013 18:18:43 -0700
Subject: RE: Possible deadloop in direct reclaim?
Message-ID: <89813612683626448B837EE5A0B6A7CB3B630BE3B0@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
 <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
 <51F69BD7.2060407@gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com>
 <51F9CBC0.2020006@gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B630BE028@SC-VEXCH4.marvell.com>
 <20130801085653.GD24642@n2100.arm.linux.org.uk>
In-Reply-To: <20130801085653.GD24642@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogUnVzc2VsbCBLaW5nIC0gQVJNIExp
bnV4IFttYWlsdG86bGludXhAYXJtLmxpbnV4Lm9yZy51a10NCj5TZW50OiAyMDEzxOo41MIxyNUg
MTY6NTcNCj5UbzogTGlzYSBEdQ0KPkNjOiBLT1NBS0kgTW90b2hpcm87IENocmlzdG9waCBMYW1l
dGVyOyBsaW51eC1tbUBrdmFjay5vcmc7IE1lbA0KPkdvcm1hbjsgQm9iIExpdTsgTmVpbCBaaGFu
Zw0KPlN1YmplY3Q6IFJlOiBQb3NzaWJsZSBkZWFkbG9vcCBpbiBkaXJlY3QgcmVjbGFpbT8NCj4N
Cj5PbiBXZWQsIEp1bCAzMSwgMjAxMyBhdCAxMDoxOTo1M1BNIC0wNzAwLCBMaXNhIER1IHdyb3Rl
Og0KPj4gPmZvcmsgYWxsb2Mgb3JkZXItMSBtZW1vcnkgZm9yIHN0YWNrLiBXaGVyZSBhbmQgd2h5
IGFsbG9jIG9yZGVyLTI/IElmIGl0IGlzDQo+PiA+YXJjaCBzcGVjaWZpYyBjb2RlLCBwbGVhc2UN
Cj4+ID5jb250YWN0IGFyY2ggbWFpbnRhaW5lci4NCj4+IFllcyBhcmNoIGRvX2ZvcmsgYWxsb2Nh
dGUgb3JkZXItMiBtZW1vcnkgd2hlbiBjb3B5X3Byb2Nlc3MuDQo+PiBIaSwgUnVzc2VsDQo+PiBX
aGF0J3MgeW91ciBvcGluaW9uIGFib3V0IHRoaXMgcXVlc3Rpb24/DQo+PiBJZiB3ZSByZWFsbHkg
bmVlZCBvcmRlci0yIG1lbW9yeSBmb3IgZm9yaywgdGhlbiB3ZSdkIGJldHRlciBzZXQNCj4+IENP
TkZJR19DT01QQVRJT04gcmlnaHQ/DQo+DQo+V2VsbCwgSSBnYXZlIHVwIHRyeWluZyB0byByZWFk
IHRoZSBvcmlnaW5hbCBtZXNzYWdlcyBiZWNhdXNlIHRoZSBxdW90aW5nDQo+c3R5bGUgaXMgYSB0
b3RhbCBtZXNzLCBzbyBJIGRvbid0IGhhdmUgYSBmdWxsIHVuZGVyc3RhbmRpbmcgb2Ygd2hhdCB0
aGUNCj5pc3N1ZSBpcy4NCkknbSByZWFsbHkgc29ycnkgZm9yIG15IHF1b3Rpbmcgc3R5bGUsIEkn
bGwgYXZvaWQgc3VjaCBpc3N1ZSBpbiBmdXR1cmUhDQo+DQo+SG93ZXZlciwgd2UgaGF2ZSBhbHdh
eXMgcmVxdWlyZWQgb3JkZXItMiBtZW1vcnkgZm9yIGZvcmssIGdvaW5nIGJhY2sgdG8NCj50aGUg
MS54IGtlcm5lbCBkYXlzIC0gaXQncyBmdW5kYW1lbnRhbCB0byBBUk0gdG8gaGF2ZSB0aGF0LiAg
VGhlIG9yZGVyLTINCj5hbGxvY2F0aW9uIG9zIGZvciB0aGUgMXN0IGxldmVsIHBhZ2UgdGFibGUu
ICBObyBvcmRlci0yIGFsbG9jYXRpb24sIG5vDQo+cGFnZSB0YWJsZXMgZm9yIHRoZSBuZXcgdGhy
ZWFkLg0KPg0KPkxvb2tpbmcgYXQgdGhpcyBjb21taXQ6DQo+DQo+Y29tbWl0IDA1MTA2ZTZhNTRh
ZWQzMjExOTFiNGJiNWM5ZWUwOTUzOGNiYWQzYjENCj5BdXRob3I6IFJpayB2YW4gUmllbCA8cmll
bEByZWRoYXQuY29tPg0KPkRhdGU6ICAgTW9uIE9jdCA4IDE2OjMzOjAzIDIwMTIgLTA3MDANCj4N
Cj4gICAgbW06IGVuYWJsZSBDT05GSUdfQ09NUEFDVElPTiBieSBkZWZhdWx0DQo+DQo+ICAgIE5v
dyB0aGF0IGx1bXB5IHJlY2xhaW0gaGFzIGJlZW4gcmVtb3ZlZCwgY29tcGFjdGlvbiBpcyB0aGUg
b25seQ0KPndheSBsZWZ0DQo+ICAgIHRvIGZyZWUgdXAgY29udGlndW91cyBtZW1vcnkgYXJlYXMu
ICBJdCBpcyB0aW1lIHRvIGp1c3QgZW5hYmxlDQo+ICAgIENPTkZJR19DT01QQUNUSU9OIGJ5IGRl
ZmF1bHQuDQo+DQo+aXQgc2VlbXMgdG8gaW5kaWNhdGUgdGhhdCBldmVyeW9uZSBzaG91bGQgaGF2
ZSB0aGlzIGVuYWJsZWQgLSBob3dldmVyLA0KPnRoZSB3YXkgdGhlIGNoYW5nZSBoYXMgYmVlbiBk
b25lLCBhbnlvbmUgYnVpbGRpbmcgZnJvbSBkZWZjb25maWdzIGJlZm9yZQ0KPnRoYXQgY2hhbmdl
IHdpbGwgbm90IGhhdmUgdGhhdCBvcHRpb24gZW5hYmxlZC4NCj4NCj5TbyB5ZXMsIHRoaXMgb3B0
aW9uIHNob3VsZCBiZSB0dXJuZWQgb24uDQpUaGFua3MgUnVzc2VsISANCkkgdGhpbmsgSSBoYXZl
IGdvdCB0aGUgaW5mb3JtYXRpb24gSSB3YW50LiBSZWFsbHkgYXBwcmVjaWF0ZSBmb3IgeW91ciBl
eHBsYW5hdGlvbiENCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

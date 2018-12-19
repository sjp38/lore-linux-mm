Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 785BC8E0008
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 18:19:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so15786829plb.18
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:19:34 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r17si16892760pls.380.2018.12.19.15.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 15:19:33 -0800 (PST)
From: "Schmauss, Erik" <erik.schmauss@intel.com>
Subject: RE: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Date: Wed, 19 Dec 2018 23:19:30 +0000
Message-ID: <CF6A88132359CE47947DB4C6E1709ED53C557D62@ORSMSX122.amr.corp.intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
 <20181211010310.8551-2-keith.busch@intel.com>
 <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com>
In-Reply-To: <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>, "Busch, Keith" <keith.busch@intel.com>, "Moore, Robert" <robert.moore@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "ACPI Devel Maling List  <linux-acpi@vger.kernel.org>, Linux Memory Management List" <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbGludXgtYWNwaS1vd25l
ckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpsaW51eC1hY3BpLQ0KPiBvd25lckB2Z2VyLmtlcm5l
bC5vcmddIE9uIEJlaGFsZiBPZiBSYWZhZWwgSi4gV3lzb2NraQ0KPiBTZW50OiBUdWVzZGF5LCBE
ZWNlbWJlciAxMSwgMjAxOCAxOjQ1IEFNDQo+IFRvOiBCdXNjaCwgS2VpdGggPGtlaXRoLmJ1c2No
QGludGVsLmNvbT4NCj4gQ2M6IExpbnV4IEtlcm5lbCBNYWlsaW5nIExpc3QgPGxpbnV4LWtlcm5l
bEB2Z2VyLmtlcm5lbC5vcmc+OyBBQ1BJIERldmVsDQo+IE1hbGluZyBMaXN0IDxsaW51eC1hY3Bp
QHZnZXIua2VybmVsLm9yZz47IExpbnV4IE1lbW9yeSBNYW5hZ2VtZW50IExpc3QNCj4gPGxpbnV4
LW1tQGt2YWNrLm9yZz47IEdyZWcgS3JvYWgtSGFydG1hbg0KPiA8Z3JlZ2toQGxpbnV4Zm91bmRh
dGlvbi5vcmc+OyBSYWZhZWwgSi4gV3lzb2NraSA8cmFmYWVsQGtlcm5lbC5vcmc+Ow0KPiBIYW5z
ZW4sIERhdmUgPGRhdmUuaGFuc2VuQGludGVsLmNvbT47IFdpbGxpYW1zLCBEYW4gSg0KPiA8ZGFu
Lmoud2lsbGlhbXNAaW50ZWwuY29tPg0KPiBTdWJqZWN0OiBSZTogW1BBVENIdjIgMDEvMTJdIGFj
cGk6IENyZWF0ZSBzdWJ0YWJsZSBwYXJzaW5nIGluZnJhc3RydWN0dXJlDQo+IA0KPiBPbiBUdWUs
IERlYyAxMSwgMjAxOCBhdCAyOjA1IEFNIEtlaXRoIEJ1c2NoIDxrZWl0aC5idXNjaEBpbnRlbC5j
b20+DQo+IHdyb3RlOg0KPiA+DQoNCkhpIFJhZmFlbCBhbmQgQm9iLA0KDQo+ID4gUGFyc2luZyBl
bnRyaWVzIGluIGFuIEFDUEkgdGFibGUgaGFkIGFzc3VtZWQgYSBnZW5lcmljIGhlYWRlcg0KPiA+
IHN0cnVjdHVyZSB0aGF0IGlzIG1vc3QgY29tbW9uLiBUaGVyZSBpcyBubyBzdGFuZGFyZCBBQ1BJ
IGhlYWRlciwNCj4gPiB0aG91Z2gsIHNvIGxlc3MgY29tbW9uIHR5cGVzIHdvdWxkIG5lZWQgY3Vz
dG9tIHBhcnNlcnMgaWYgdGhleSB3YW50IGdvDQo+ID4gdGhyb3VnaCB0aGVpciBzdWItdGFibGUg
ZW50cnkgbGlzdC4NCj4gDQo+IEl0IGxvb2tzIGxpa2UgdGhlIHByb2JsZW0gYXQgaGFuZCBpcyB0
aGF0IGFjcGlfaG1hdF9zdHJ1Y3R1cmUgaXMgaW5jb21wYXRpYmxlDQo+IHdpdGggYWNwaV9zdWJ0
YWJsZV9oZWFkZXIgYmVjYXVzZSBvZiB0aGUgZGlmZmVyZW50IGxheW91dCBhbmQgZmllbGQgc2l6
ZXMuDQoNCkp1c3Qgb3V0IG9mIGN1cmlvc2l0eSwgd2h5IGRvbid0IHdlIHVzZSBBQ1BJQ0EgY29k
ZSB0byBwYXJzZSBzdGF0aWMgQUNQSSB0YWJsZXMNCmluIExpbnV4Pw0KDQpXZSBoYXZlIGEgZGlz
YXNzZW1ibGVyIGZvciBzdGF0aWMgdGFibGVzIHRoYXQgcGFyc2VzIGFsbCBzdXBwb3J0ZWQgdGFi
bGVzLiBUaGlzDQpzZWVtcyBsaWtlIGEgZHVwbGljYXRpb24gb2YgY29kZS9lZmZvcnQuLi4NCg0K
RXJpaw0KPiANCj4gSWYgc28sIHBsZWFzZSBzdGF0ZSB0aGF0IGNsZWFybHkgaGVyZS4NCj4gDQo+
IFdpdGggdGhhdCwgcGxlYXNlIGZlZWwgZnJlZSB0byBhZGQNCj4gDQo+IFJldmlld2VkLWJ5OiBS
YWZhZWwgSi4gV3lzb2NraSA8cmFmYWVsLmoud3lzb2NraUBpbnRlbC5jb20+DQo+IA0KPiB0byB0
aGlzIHBhdGNoLg0K

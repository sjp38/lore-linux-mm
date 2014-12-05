Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C86A26B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 03:08:54 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so241251pdi.16
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 00:08:54 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id zq10si46371650pbc.218.2014.12.05.00.08.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 00:08:53 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 5 Dec 2014 16:08:42 +0800
Subject: RE: [RFC V2] mm:add zero_page _mapcount when mapped into user space
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313EC@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313E0@CNBJMBX05.corpusers.net>
	<20141202113014.GA22683@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313E6@CNBJMBX05.corpusers.net>
	<20141204122813.GA523@node.dhcp.inet.fi>
 <CALYGNiPWw6=tryWn_kCs+6H1uSjApBDnqORxuNEd=DuGCo71qA@mail.gmail.com>
In-Reply-To: <CALYGNiPWw6=tryWn_kCs+6H1uSjApBDnqORxuNEd=DuGCo71qA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Konstantin Khlebnikov' <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBLb25zdGFudGluIEtobGVibmlr
b3YgW21haWx0bzprb2N0OWlAZ21haWwuY29tXQ0KPiBTZW50OiBGcmlkYXksIERlY2VtYmVyIDA1
LCAyMDE0IDI6MzkgUE0NCj4gVG86IEtpcmlsbCBBLiBTaHV0ZW1vdg0KPiBDYzogV2FuZywgWWFs
aW47IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGlu
dXgtDQo+IGFybS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZw0KPiBTdWJqZWN0OiBSZTogW1JG
QyBWMl0gbW06YWRkIHplcm9fcGFnZSBfbWFwY291bnQgd2hlbiBtYXBwZWQgaW50byB1c2VyDQo+
IHNwYWNlDQo+IA0KPiBPbiBUaHUsIERlYyA0LCAyMDE0IGF0IDM6MjggUE0sIEtpcmlsbCBBLiBT
aHV0ZW1vdiA8a2lyaWxsQHNodXRlbW92Lm5hbWU+DQo+IHdyb3RlOg0KPiA+IE9uIFRodSwgRGVj
IDA0LCAyMDE0IGF0IDAyOjEwOjUzUE0gKzA4MDAsIFdhbmcsIFlhbGluIHdyb3RlOg0KPiA+PiA+
IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4+ID4gRnJvbTogS2lyaWxsIEEuIFNodXRl
bW92IFttYWlsdG86a2lyaWxsQHNodXRlbW92Lm5hbWVdDQo+ID4+ID4gU2VudDogVHVlc2RheSwg
RGVjZW1iZXIgMDIsIDIwMTQgNzozMCBQTQ0KPiA+PiA+IFRvOiBXYW5nLCBZYWxpbg0KPiA+PiA+
IENjOiAnbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZyc7ICdsaW51eC1tbUBrdmFjay5vcmcn
Ow0KPiA+PiA+ICdsaW51eC1hcm0tIGtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnJw0KPiA+PiA+
IFN1YmplY3Q6IFJlOiBbUkZDIFYyXSBtbTphZGQgemVyb19wYWdlIF9tYXBjb3VudCB3aGVuIG1h
cHBlZCBpbnRvDQo+ID4+ID4gdXNlciBzcGFjZQ0KPiA+PiA+DQo+ID4+ID4gT24gVHVlLCBEZWMg
MDIsIDIwMTQgYXQgMDU6Mjc6MzZQTSArMDgwMCwgV2FuZywgWWFsaW4gd3JvdGU6DQo+ID4+ID4g
PiBUaGlzIHBhdGNoIGFkZC9kZWMgemVyb19wYWdlJ3MgX21hcGNvdW50IHRvIG1ha2Ugc3VyZSB0
aGUNCj4gPj4gPiA+IG1hcGNvdW50IGlzIGNvcnJlY3QgZm9yIHplcm9fcGFnZSwgc28gdGhhdCB3
aGVuIHJlYWQgZnJvbQ0KPiA+PiA+ID4gL3Byb2Mva3BhZ2Vjb3VudCwgemVyb19wYWdlJ3MgbWFw
Y291bnQgaXMgYWxzbyBjb3JyZWN0LCB1c2Vyc3BhY2UNCj4gPj4gPiA+IHByb2Nlc3MgbGlrZSBw
cm9jcmFuayBjYW4gY2FsY3VsYXRlIFBTUyBjb3JyZWN0bHkuDQo+IA0KPiBJbnN0ZWFkIG9mIHR3
ZWFraW5nIG1hcGNvdW50IHlvdSBjb3VsZCBtYXJrIHplcm8tcGFnZXMgaW4gL3Byb2Mva3BhZ2Vm
bGFncw0KPiBhbmQgaGFuZGxlIHRoZW0gYWNjb3JkaW5nbHkgaW4gdXNlcnNwYWNlLiBPciBtYXJr
IHplcm8gcGFnZXMgd2l0aCBzcGVjaWFsDQo+IG1hZ2ljIF9tYXBjb3VudCBhbmQgZGV0ZWN0IGl0
IGluIC9wcm9jL2twYWdlY291bnQuDQo+IA0KSSB0aGluayBhZGQgS1BGX1pFUk9fUEFHRSBpbiBr
cGFnZWZsYWdzIGlzIGJldHRlci4NCkkgd2lsbCBtYWtlIGFub3RoZXIgcGF0Y2ggZm9yIHJldmll
dyAuDQoNClRoYW5rcw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

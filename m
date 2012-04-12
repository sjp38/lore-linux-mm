Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 84E976B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 04:34:07 -0400 (EDT)
From: "Luca Porzio (lporzio)" <lporzio@micron.com>
Subject: RE: swap on eMMC and other flash
Date: Thu, 12 Apr 2012 08:32:57 +0000
Message-ID: <26E7A31274623843B0E8CF86148BFE326FB5AEE2@NTXAVZMBX04.azit.micron.com>
References: <201203301744.16762.arnd@arndb.de>
 <201204091300.34304.arnd@arndb.de> <4F838870.9030407@kernel.org>
 <201204100840.11763.arnd@arndb.de>
In-Reply-To: <201204100840.11763.arnd@arndb.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Minchan Kim <minchan@kernel.org>
Cc: =?utf-8?B?7KCV7Zqo7KeE?= <syr.jeong@samsung.com>, 'Alex Lemberg' <Alex.Lemberg@sandisk.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, 'Rik van Riel' <riel@redhat.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@android.com" <kernel-team@android.com>, 'Yejin Moon' <yejin.moon@samsung.com>, 'Hugh
 Dickins' <hughd@google.com>, 'Yaniv Iarovici' <Yaniv.Iarovici@sandisk.com>, "cpgs@samsung.com" <cpgs@samsung.com>

SGkgQWxsLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGxpbnV4LW1t
Yy1vd25lckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpsaW51eC1tbWMtb3duZXJAdmdlci5rZXJu
ZWwub3JnXQ0KPiBPbiBCZWhhbGYgT2YgQXJuZCBCZXJnbWFubg0KPiBTZW50OiBUdWVzZGF5LCBB
cHJpbCAxMCwgMjAxMiAxOjQwIEFNDQo+IFRvOiBNaW5jaGFuIEtpbQ0KPiBDYzog7KCV7Zqo7KeE
OyAnQWxleCBMZW1iZXJnJzsgbGluYXJvLWtlcm5lbEBsaXN0cy5saW5hcm8ub3JnOyAnUmlrIHZh
biBSaWVsJzsNCj4gbGludXgtbW1jQHZnZXIua2VybmVsLm9yZzsgbGludXgta2VybmVsQHZnZXIu
a2VybmVsLm9yZzsgTHVjYSBQb3J6aW8NCj4gKGxwb3J6aW8pOyBsaW51eC1tbUBrdmFjay5vcmc7
IGtlcm5lbC10ZWFtQGFuZHJvaWQuY29tOyAnWWVqaW4gTW9vbic7ICdIdWdoDQo+IERpY2tpbnMn
OyAnWWFuaXYgSWFyb3ZpY2knOyBjcGdzQHNhbXN1bmcuY29tDQo+IFN1YmplY3Q6IFJlOiBzd2Fw
IG9uIGVNTUMgYW5kIG90aGVyIGZsYXNoDQo+IA0KPiBPbiBUdWVzZGF5IDEwIEFwcmlsIDIwMTIs
IE1pbmNoYW4gS2ltIHdyb3RlOg0KPiA+IEkgdGhpbmsgaXQncyBub3QgZ29vZCBhcHByb2FjaC4N
Cj4gPiBIb3cgbG9uZyBkb2VzIGl0IHRha2UgdG8ga25vdyBzdWNoIHBhcmFtZXRlcnM/DQo+ID4g
SSBndWVzcyBpdCdzIG5vdCBzaG9ydCBzbyB0aGF0IG1rZnMvbWtzd2FwIHdvdWxkIGJlIHZlcnkg
bG9uZw0KPiA+IGRyYW1hdGljYWxseS4gSWYgbmVlZGVkLCBsZXQncyBtYWludGFpbiBpdCBhcyBh
bm90aGVyIHRvb2wuDQo+IA0KPiBJIGhhdmVuJ3QgY29tZSB1cCB3aXRoIGEgd2F5IHRoYXQgaXMg
Ym90aCBmYXN0IGFuZCByZWxpYWJsZS4NCj4gQSB2ZXJ5IGZhc3QgbWV0aG9kIGlzIHRvIHRpbWUg
c2hvcnQgcmVhZCByZXF1ZXN0cyBhY3Jvc3MgcG90ZW50aWFsDQo+IGVyYXNlIGJsb2NrIGJvdW5k
YXJpZXMgYW5kIHNlZSB3aGljaCBvbmVzIGFyZSBmYXN0ZXIgdGhhbiBvdGhlcnMsDQo+IHRoaXMg
d29ya3Mgb24gYWJvdXQgMyBvdXQgb2YgNCBkZXZpY2VzLg0KPiANCj4gRm9yIHRoZSBvdGhlciBk
ZXZpY2VzLCBJIGN1cnJlbnRseSB1c2UgYSBmYWlybHkgbWFudWFsIHByb2Nlc3MgdGhhdA0KPiB0
aW1lcyBhIGxvdCBvZiB3cml0ZSByZXF1ZXN0cyBhbmQgY2FuIHRha2UgYSBsb25nIHRpbWUuDQo+
IA0KPiA+IElmIHN0b3JhZ2UgdmVuZG9ycyBicmVhayBzdWNoIGZpZWxkcywgaXQgZG9lc24ndCB3
b3JrIHdlbGwgb24gbGludXgNCj4gPiB3aGljaCBpcyB2ZXJ5IHBvcHVsYXIgb24gbW9iaWxlIHdv
cmxkIHRvZGF5IGFuZCB1c2VyIHdpbGwgbm90IHVzZSBzdWNoDQo+ID4gdmVuZG9yIGRldmljZXMg
YW5kIGNvbXBhbnkgd2lsbCBiZSBnb25lLiBMZXQncyBnaXZlIHN1Y2ggcHJlc3N1cmUgdG8NCj4g
PiB0aGVtIGFuZCBtYWtlIHZlbmRvciBrZWVwIGluIHByb21pc2UuDQo+IA0KPiBUaGlzIGNvdWxk
IHdvcmsgZm9yIGVNTUMsIHllcy4NCj4gDQoNCkkgbGlrZSBpdCA7KQ0KDQo+IFRoZSBTRCBjYXJk
IHN0YW5kYXJkIG1ha2VzIGl0IGltcG9zc2libGUgdG8gd3JpdGUgdGhlIGNvcnJlY3QgdmFsdWUg
Zm9yDQo+IG1vc3QgZGV2aWNlcywgaXQgb25seSBzdXBwb3J0cyBwb3dlci1vZi10d28gdmFsdWVz
IHVwIHRvIDRNQiBmb3IgU0RIQywNCj4gYW5kIGxhcmdlciB2YWx1ZXMgKEkgYmVsaWV2ZSA4LCAx
MiwgMTYsIDI0LCAuLi4gNjQpIGZvciBTRFhDLCBidXQgYSBsb3QNCj4gb2YgU0RIQyBjYXJkcyBu
b3dhZGF5cyB1c2UgMS41LCAzLCA2IG9yIDggTUIgZXJhc2UgYmxvY2tzLg0KPiANCj4gCUFybmQN
Cj4gLS0NCj4gVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVu
c3Vic2NyaWJlIGxpbnV4LW1tYyIgaW4NCj4gdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9y
ZG9tb0B2Z2VyLmtlcm5lbC5vcmcNCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3Zn
ZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

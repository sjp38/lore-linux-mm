Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 559F06B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:00:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x2-v6so2378818wmc.3
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:00:48 -0700 (PDT)
Received: from mx07-00178001.pphosted.com (mx08-00178001.pphosted.com. [91.207.212.93])
        by mx.google.com with ESMTPS id n28-v6si1913080edn.15.2018.05.14.01.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 01:00:46 -0700 (PDT)
From: Fabien DESSENNE <fabien.dessenne@st.com>
Subject: Re: Are media drivers abusing of GFP_DMA? - was: Re: [LSF/MM TOPIC
 NOTES] x86 ZONE_DMA love
Date: Mon, 14 May 2018 08:00:37 +0000
Message-ID: <547252fc-dc74-93c6-fc77-be1bfb558787@st.com>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180505130815.53a26955@vento.lan> <3561479.qPIcrWnXEC@avalon>
 <20180507121916.4eb7f5b2@vento.lan>
In-Reply-To: <20180507121916.4eb7f5b2@vento.lan>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D628BB47A8DF0541A38FCEAB49C4D57A@st.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Jean Christophe TROTIN <jean-christophe.trotin@st.com>, Yasunari Takiguchi <Yasunari.Takiguchi@sony.com>, Sakari Ailus <sakari.ailus@linux.intel.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

DQoNCk9uIDA3LzA1LzE4IDE3OjE5LCBNYXVybyBDYXJ2YWxobyBDaGVoYWIgd3JvdGU6DQo+IEVt
IE1vbiwgMDcgTWF5IDIwMTggMTY6MjY6MDggKzAzMDANCj4gTGF1cmVudCBQaW5jaGFydCA8bGF1
cmVudC5waW5jaGFydEBpZGVhc29uYm9hcmQuY29tPiBlc2NyZXZldToNCj4NCj4+IEhpIE1hdXJv
LA0KPj4NCj4+IE9uIFNhdHVyZGF5LCA1IE1heSAyMDE4IDE5OjA4OjE1IEVFU1QgTWF1cm8gQ2Fy
dmFsaG8gQ2hlaGFiIHdyb3RlOg0KPj4+IFRoZXJlIHdhcyBhIHJlY2VudCBkaXNjdXNzaW9uIGFi
b3V0IHRoZSB1c2UvYWJ1c2Ugb2YgR0ZQX0RNQSBmbGFnIHdoZW4NCj4+PiBhbGxvY2F0aW5nIG1l
bW9yaWVzIGF0IExTRi9NTSAyMDE4IChzZWUgTHVpcyBub3RlcyBlbmNsb3NlZCkuDQo+Pj4NCj4+
PiBUaGUgaWRlYSBzZWVtcyB0byBiZSB0byByZW1vdmUgaXQsIHVzaW5nIENNQSBpbnN0ZWFkLiBC
ZWZvcmUgZG9pbmcgdGhhdCwNCj4+PiBiZXR0ZXIgdG8gY2hlY2sgaWYgd2hhdCB3ZSBoYXZlIG9u
IG1lZGlhIGlzIGFyZSB2YWxpZCB1c2UgY2FzZXMgZm9yIGl0LCBvcg0KPj4+IGlmIGl0IGlzIHRo
ZXJlIGp1c3QgZHVlIHRvIHNvbWUgbWlzdW5kZXJzdGFuZGluZyAob3IgYmVjYXVzZSBpdCB3YXMN
Cj4+PiBjb3BpZWQgZnJvbSBzb21lIG90aGVyIGNvZGUpLg0KPj4+DQo+Pj4gSGFucyBkZSBHb2Vk
ZSBzZW50IHVzIHRvZGF5IGEgcGF0Y2ggc3RvcHBpbmcgYWJ1c2UgYXQgZ3NwY2EsIGFuZCBJJ20N
Cj4+PiBhbHNvIHBvc3RpbmcgdG9kYXkgdHdvIG90aGVyIHBhdGNoZXMgbWVhbnQgdG8gc3RvcCBh
YnVzZSBvZiBpdCBvbiBVU0INCj4+PiBkcml2ZXJzLiBTdGlsbCwgdGhlcmUgYXJlIDQgcGxhdGZv
cm0gZHJpdmVycyB1c2luZyBpdDoNCj4+Pg0KPj4+IAkkIGdpdCBncmVwIC1sIC1FICJHRlBfRE1B
XFxiIiBkcml2ZXJzL21lZGlhLw0KPj4+IAlkcml2ZXJzL21lZGlhL3BsYXRmb3JtL29tYXAzaXNw
L2lzcHN0YXQuYw0KPj4+IAlkcml2ZXJzL21lZGlhL3BsYXRmb3JtL3N0aS9iZGlzcC9iZGlzcC1o
dy5jDQo+Pj4gCWRyaXZlcnMvbWVkaWEvcGxhdGZvcm0vc3RpL2h2YS9odmEtbWVtLmMNCg0KSGkg
TWF1cm8sDQoNClRoZSB0d28gU1RJIGRyaXZlcnMgKGJkaXNwLWh3LmMgYW5kIGh2YS1tZW0uYykg
YXJlIG9ubHkgZXhwZWN0ZWQgdG8gcnVuIA0Kb24gQVJNIHBsYXRmb3Jtcywgbm90IG9uIHg4Ni4N
ClNpbmNlIHRoaXMgdGhyZWFkIGRlYWxzIHdpdGggeDg2ICYgRE1BIHRyb3VibGUsIEkgYW0gbm90
IHN1cmUgdGhhdCB3ZSANCmFjdHVhbGx5IGhhdmUgYSBwcm9ibGVtIGZvciB0aGUgc3RpIGRyaXZl
cnMuDQoNClRoZXJlIGFyZSBzb21lIG90aGVyIHN0aSBkcml2ZXJzIHRoYXQgbWFrZSB1c2Ugb2Yg
dGhpcyBHRlBfRE1BIGZsYWcgDQooZHJpdmVycy9ncHUvZHJtL3N0aS9zdGlfKi5jKSBhbmQgaXQg
ZG9lcyBub3Qgc2VlbSB0byBiZSBhIHByb2JsZW0uDQoNCk5ldmVydGhlbGVzcyBJIGNhbiBzZWUg
dGhhdCB0aGUgbWVkaWEgc3RpIGRyaXZlcnMgZGVwZW5kIG9uIENPTVBJTEVfVEVTVCANCih3aGlj
aCBpcyBub3QgdGhlIGNhc2UgZm9yIHRoZSBEUk0gb25lcykuDQpXb3VsZCBpdCBiZSBhbiBhY2Nl
cHRhYmxlIHNvbHV0aW9uIHRvIHJlbW92ZSB0aGUgQ09NUElMRV9URVNUIGRlcGVuZGVuY3k/DQoN
CkJSDQoNCkZhYmllbg0KDQo+Pj4gCWRyaXZlcnMvbWVkaWEvc3BpL2N4ZDI4ODAtc3BpLmMNCj4+
Pg0KPj4+IENvdWxkIHlvdSBwbGVhc2UgY2hlY2sgaWYgR0ZQX0RNQSBpcyByZWFsbHkgbmVlZGVk
IHRoZXJlLCBvciBpZiBpdCBpcw0KPj4+IGp1c3QgYmVjYXVzZSBvZiBzb21lIGN1dC1hbmQtcGFz
dGUgZnJvbSBzb21lIG90aGVyIHBsYWNlPw0KPj4gSSBzdGFydGVkIGxvb2tpbmcgYXQgdGhhdCBm
b3IgdGhlIG9tYXAzaXNwIGRyaXZlciBidXQgU2FrYXJpIGJlYXQgbWUgYXQNCj4+IHN1Ym1pdHRp
bmcgYSBwYXRjaC4gR0ZQX0RNQSBpc24ndCBuZWVkZWQgZm9yIG9tYXAzaXNwLg0KPj4NCj4gVGhh
bmsgeW91IGJvdGggZm9yIGxvb2tpbmcgaW50byBpdC4NCj4NCj4gUmVnYXJkcywNCj4gTWF1cm8N
Cj4NCj4NCj4NCj4gVGhhbmtzLA0KPiBNYXVybw0K

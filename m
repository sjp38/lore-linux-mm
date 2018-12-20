Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66B7E8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:08:41 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so1754617pfb.13
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 06:08:41 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790080.outbound.protection.outlook.com. [40.107.79.80])
        by mx.google.com with ESMTPS id j1si18514056pff.42.2018.12.20.06.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 06:08:40 -0800 (PST)
From: "StDenis, Tom" <Tom.StDenis@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Thu, 20 Dec 2018 14:08:38 +0000
Message-ID: <fbdd541c-ce31-9fe0-f1ac-bb9c51bb6526@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com>
 <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
 <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
 <CABXGCsMygWFqnkaZbpLEBd9aBkk9=-fRnDMNOnkRfPZaeheoCg@mail.gmail.com>
 <9b87556e-ed4d-6ec0-2f98-a08469b7f35e@amd.com>
 <CABXGCsMbP8W28NTx_y3viiN=3deiEVkLw0_HBFZa1Qt_8MUVjg@mail.gmail.com>
 <b3aba7f4-b131-64fe-88eb-c1e14e133c51@amd.com>
 <CABXGCsMJs6X+bK7NS+wPn94H3skcR5a-U9710rSByvn26vg7Gg@mail.gmail.com>
 <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com>
In-Reply-To: <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4407B5F62A517547AFEE756E18EF52C9@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

T24gMjAxOC0xMi0yMCA5OjA2IGEubS4sIFRvbSBTdCBEZW5pcyB3cm90ZToNCj4gT24gMjAxOC0x
Mi0yMCA2OjQ1IGEubS4sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+PiBPbiBUaHUsIDIwIERl
YyAyMDE4IGF0IDE2OjE3LCBTdERlbmlzLCBUb20gPFRvbS5TdERlbmlzQGFtZC5jb20+IHdyb3Rl
Og0KPj4+DQo+Pj4gV2VsbCB5dXAgdGhlIGtlcm5lbCBpcyBub3QgbGV0dGluZyB5b3Ugb3BlbiB0
aGUgZmlsZXM6DQo+Pj4NCj4+Pg0KPj4+IEFzIHN1ZG8vcm9vdCB5b3Ugc2hvdWxkIGJlIGFibGUg
dG8gb3BlbiB0aGVzZSBmaWxlcyB3aXRoIHVtci7CoCBXaGF0DQo+Pj4gaGFwcGVucyBpZiB5b3Ug
anVzdCBvcGVuIGEgc2hlbGwgYXMgcm9vdCBhbmQgcnVuIGl0Pw0KPj4+DQo+Pg0KPj4gW3Jvb3RA
bG9jYWxob3N0IH5dIyB0b3VjaCAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRncHVfcmluZ19n
ZngNCj4+IFtyb290QGxvY2FsaG9zdCB+XSMgY2F0IC9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2Ft
ZGdwdV9yaW5nX2dmeA0KPj4gY2F0OiAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRncHVfcmlu
Z19nZng6IE9wZXJhdGlvbiBub3QgcGVybWl0dGVkDQo+PiBbcm9vdEBsb2NhbGhvc3Qgfl0jIGxz
IC1sYVogL3N5cy9rZXJuZWwvZGVidWcvZHJpLzAvYW1kZ3B1X3JpbmdfZ2Z4DQo+PiAtci0tci0t
ci0tLiAxIHJvb3Qgcm9vdCBzeXN0ZW1fdTpvYmplY3RfcjpkZWJ1Z2ZzX3Q6czAgODIwNCBEZWMg
MjANCj4+IDE2OjMxIC9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2FtZGdwdV9yaW5nX2dmeA0KPj4g
W3Jvb3RAbG9jYWxob3N0IH5dIyBnZXRlbmZvcmNlDQo+PiBQZXJtaXNzaXZlDQo+PiBbcm9vdEBs
b2NhbGhvc3Qgfl0jIC9ob21lL21pa2hhaWwvcGFja2FnaW5nLXdvcmsvdW1yL2J1aWxkL3NyYy9h
cHAvdW1yDQo+PiAtTyB2ZXJib3NlLGhhbHRfd2F2ZXMgLXdhDQo+PiBDYW5ub3Qgc2VlayB0byBN
TUlPIGFkZHJlc3M6IEJhZCBmaWxlIGRlc2NyaXB0b3INCj4+IFtFUlJPUl06IENvdWxkIG5vdCBv
cGVuIHJpbmcgZGVidWdmcyBmaWxlU2VnbWVudGF0aW9uIGZhdWx0IChjb3JlIGR1bXBlZCkNCj4+
DQo+PiBJIGFtIGFscmVhZHkgdHJpZWQgbGF1bmNoIGB1bXJgIHVuZGVyIHJvb3QgdXNlciwgYnV0
IGtlcm5lbCBkb24ndCBsZXQNCj4+IG9wZW4gYGFtZGdwdV9yaW5nX2dmeGAgYWdhaW4uDQo+Pg0K
Pj4gV2hhdCBlbHNlIGtlcm5lbCBvcHRpb25zIEkgc2hvdWxkIHRvIGNoZWNrPw0KPj4NCj4+IEkg
YW0gYWxzbyBhdHRhY2hlZCBjdXJyZW50IGtlcm5lbCBjb25maWcgdG8gdGhpcyBtZXNzYWdlLg0K
PiANCj4gSSBjYW4gcmVwbGljYXRlIHRoaXMgYnkgZG9pbmcNCj4gDQo+IGNobW9kIHUrcyB1bXIN
Cj4gc3VkbyAuL3VtciAtUiBnZnhbLl0NCj4gDQo+IFlvdSBuZWVkIHRvIHJlbW92ZSB0aGUgdStz
IGJpdCB5b3UgYXJlIGxpdGVyYWxseSBub3QgcnVubmluZyB1bXIgYXMgcm9vdCENCg0KQWN0dWFs
bHkgZGlzcmVnYXJkIHRoYXQuICBJJ20gY29uZnVzZWQgYXQgdGhpcyBwb2ludC4NCg0KSSBydW4g
dW1yIDEwMHMgb2YgdGltZXMgYSBkYXkgb24gbXkgZGV2ZWwgYm94IGp1c3QgZmluZSBhcyByb290
Lg0KDQpMZXQgbWUgZmlkZGxlIGFuZCBzZWUgaWYgSSBjYW4gc29ydCB0aGlzIG91dC4NCg0KVG9t
DQo=

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E65168E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:06:55 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id x2so1165054ioa.23
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 06:06:55 -0800 (PST)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680073.outbound.protection.outlook.com. [40.107.68.73])
        by mx.google.com with ESMTPS id u4si4324181itj.4.2018.12.20.06.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 06:06:54 -0800 (PST)
From: "StDenis, Tom" <Tom.StDenis@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Thu, 20 Dec 2018 14:06:47 +0000
Message-ID: <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com>
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
In-Reply-To: 
 <CABXGCsMJs6X+bK7NS+wPn94H3skcR5a-U9710rSByvn26vg7Gg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D68B6D7D4D4FEF42A4DB827C07800425@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

T24gMjAxOC0xMi0yMCA2OjQ1IGEubS4sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+IE9uIFRo
dSwgMjAgRGVjIDIwMTggYXQgMTY6MTcsIFN0RGVuaXMsIFRvbSA8VG9tLlN0RGVuaXNAYW1kLmNv
bT4gd3JvdGU6DQo+Pg0KPj4gV2VsbCB5dXAgdGhlIGtlcm5lbCBpcyBub3QgbGV0dGluZyB5b3Ug
b3BlbiB0aGUgZmlsZXM6DQo+Pg0KPj4NCj4+IEFzIHN1ZG8vcm9vdCB5b3Ugc2hvdWxkIGJlIGFi
bGUgdG8gb3BlbiB0aGVzZSBmaWxlcyB3aXRoIHVtci4gIFdoYXQNCj4+IGhhcHBlbnMgaWYgeW91
IGp1c3Qgb3BlbiBhIHNoZWxsIGFzIHJvb3QgYW5kIHJ1biBpdD8NCj4+DQo+IA0KPiBbcm9vdEBs
b2NhbGhvc3Qgfl0jIHRvdWNoIC9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2FtZGdwdV9yaW5nX2dm
eA0KPiBbcm9vdEBsb2NhbGhvc3Qgfl0jIGNhdCAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRn
cHVfcmluZ19nZngNCj4gY2F0OiAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRncHVfcmluZ19n
Zng6IE9wZXJhdGlvbiBub3QgcGVybWl0dGVkDQo+IFtyb290QGxvY2FsaG9zdCB+XSMgbHMgLWxh
WiAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRncHVfcmluZ19nZngNCj4gLXItLXItLXItLS4g
MSByb290IHJvb3Qgc3lzdGVtX3U6b2JqZWN0X3I6ZGVidWdmc190OnMwIDgyMDQgRGVjIDIwDQo+
IDE2OjMxIC9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2FtZGdwdV9yaW5nX2dmeA0KPiBbcm9vdEBs
b2NhbGhvc3Qgfl0jIGdldGVuZm9yY2UNCj4gUGVybWlzc2l2ZQ0KPiBbcm9vdEBsb2NhbGhvc3Qg
fl0jIC9ob21lL21pa2hhaWwvcGFja2FnaW5nLXdvcmsvdW1yL2J1aWxkL3NyYy9hcHAvdW1yDQo+
IC1PIHZlcmJvc2UsaGFsdF93YXZlcyAtd2ENCj4gQ2Fubm90IHNlZWsgdG8gTU1JTyBhZGRyZXNz
OiBCYWQgZmlsZSBkZXNjcmlwdG9yDQo+IFtFUlJPUl06IENvdWxkIG5vdCBvcGVuIHJpbmcgZGVi
dWdmcyBmaWxlU2VnbWVudGF0aW9uIGZhdWx0IChjb3JlIGR1bXBlZCkNCj4gDQo+IEkgYW0gYWxy
ZWFkeSB0cmllZCBsYXVuY2ggYHVtcmAgdW5kZXIgcm9vdCB1c2VyLCBidXQga2VybmVsIGRvbid0
IGxldA0KPiBvcGVuIGBhbWRncHVfcmluZ19nZnhgIGFnYWluLg0KPiANCj4gV2hhdCBlbHNlIGtl
cm5lbCBvcHRpb25zIEkgc2hvdWxkIHRvIGNoZWNrPw0KPiANCj4gSSBhbSBhbHNvIGF0dGFjaGVk
IGN1cnJlbnQga2VybmVsIGNvbmZpZyB0byB0aGlzIG1lc3NhZ2UuDQoNCkkgY2FuIHJlcGxpY2F0
ZSB0aGlzIGJ5IGRvaW5nDQoNCmNobW9kIHUrcyB1bXINCnN1ZG8gLi91bXIgLVIgZ2Z4Wy5dDQoN
CllvdSBuZWVkIHRvIHJlbW92ZSB0aGUgdStzIGJpdCB5b3UgYXJlIGxpdGVyYWxseSBub3QgcnVu
bmluZyB1bXIgYXMgcm9vdCENCg0KOi0pDQoNClRvbQ0KDQoNCj4gDQo+IC0tDQo+IEJlc3QgUmVn
YXJkcywNCj4gTWlrZSBHYXZyaWxvdi4NCj4gDQoNCg==

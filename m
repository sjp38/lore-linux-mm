Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 655468E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 06:18:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l22so1393737pfb.2
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 03:18:01 -0800 (PST)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730072.outbound.protection.outlook.com. [40.107.73.72])
        by mx.google.com with ESMTPS id o3si18675794pgq.139.2018.12.20.03.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 03:17:59 -0800 (PST)
From: "StDenis, Tom" <Tom.StDenis@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Thu, 20 Dec 2018 11:17:56 +0000
Message-ID: <b3aba7f4-b131-64fe-88eb-c1e14e133c51@amd.com>
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
In-Reply-To: 
 <CABXGCsMbP8W28NTx_y3viiN=3deiEVkLw0_HBFZa1Qt_8MUVjg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <63C2D45E6C455B4880A735D056DCDD6D@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

T24gMjAxOC0xMi0xOSAxMDoyOSBwLm0uLCBNaWtoYWlsIEdhdnJpbG92IHdyb3RlOg0KPiBPbiBU
aHUsIDIwIERlYyAyMDE4IGF0IDAzOjQxLCBTdERlbmlzLCBUb20gPFRvbS5TdERlbmlzQGFtZC5j
b20+IHdyb3RlOg0KPiANCj4+IHN1ZG8gc3RyYWNlIHVtciAtUiBnZnhbLl0gMj4mMSB8IHRlZSBz
dHJhY2UubG9nDQo+Pg0KPj4gd2lsbCBjYXB0dXJlIGV2ZXJ5dGhpbmcuDQo+Pg0KPj4gSW4gdGhl
IG1lYW4gdGltZSBJIGNhbiBmaXggYXQgbGVhc3QgdGhlIHNlZ2ZhdWx0Lg0KPj4NCj4+IFRoZSBp
c3N1ZSBpcyB3aHkgY2FuJ3QgaXQgb3BlbiAiYW1kZ3B1X3JpbmdfZ2Z4Ii4NCj4+DQo+PiBUb20N
Cj4+DQo+IA0KPiBzdHJhY2UgZmlsZSBpcyBhdHRhY2hlZCBoZXJlLg0KDQpXZWxsIHl1cCB0aGUg
a2VybmVsIGlzIG5vdCBsZXR0aW5nIHlvdSBvcGVuIHRoZSBmaWxlczoNCg0Kb3BlbmF0KEFUX0ZE
Q1dELCAiL3N5cy9rZXJuZWwvZGVidWcvZHJpLzAvYW1kZ3B1X2djYV9jb25maWciLCBPX1JET05M
WSkgDQo9IC0xIEVQRVJNIChPcGVyYXRpb24gbm90IHBlcm1pdHRlZCkNCm9wZW5hdChBVF9GRENX
RCwgIi9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2FtZGdwdV9yZWdzIiwgT19SRFdSKSA9IC0xIA0K
RVBFUk0gKE9wZXJhdGlvbiBub3QgcGVybWl0dGVkKQ0Kb3BlbmF0KEFUX0ZEQ1dELCAiL3N5cy9r
ZXJuZWwvZGVidWcvZHJpLzAvYW1kZ3B1X3JlZ3NfZGlkdCIsIE9fUkRXUikgPSANCi0xIEVQRVJN
IChPcGVyYXRpb24gbm90IHBlcm1pdHRlZCkNCm9wZW5hdChBVF9GRENXRCwgIi9zeXMva2VybmVs
L2RlYnVnL2RyaS8wL2FtZGdwdV9yZWdzX3BjaWUiLCBPX1JEV1IpID0gDQotMSBFUEVSTSAoT3Bl
cmF0aW9uIG5vdCBwZXJtaXR0ZWQpDQpvcGVuYXQoQVRfRkRDV0QsICIvc3lzL2tlcm5lbC9kZWJ1
Zy9kcmkvMC9hbWRncHVfcmVnc19zbWMiLCBPX1JEV1IpID0gLTEgDQpFUEVSTSAoT3BlcmF0aW9u
IG5vdCBwZXJtaXR0ZWQpDQpvcGVuYXQoQVRfRkRDV0QsICIvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkv
MC9hbWRncHVfc2Vuc29ycyIsIE9fUkRXUikgPSAtMSANCkVQRVJNIChPcGVyYXRpb24gbm90IHBl
cm1pdHRlZCkNCm9wZW5hdChBVF9GRENXRCwgIi9zeXMva2VybmVsL2RlYnVnL2RyaS8wL2FtZGdw
dV93YXZlIiwgT19SRFdSKSA9IC0xIA0KRVBFUk0gKE9wZXJhdGlvbiBub3QgcGVybWl0dGVkKQ0K
b3BlbmF0KEFUX0ZEQ1dELCAiL3N5cy9rZXJuZWwvZGVidWcvZHJpLzAvYW1kZ3B1X3ZyYW0iLCBP
X1JEV1IpID0gLTEgDQpFUEVSTSAoT3BlcmF0aW9uIG5vdCBwZXJtaXR0ZWQpDQpvcGVuYXQoQVRf
RkRDV0QsICIvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC9hbWRncHVfZ3ByIiwgT19SRFdSKSA9IC0x
IA0KRVBFUk0gKE9wZXJhdGlvbiBub3QgcGVybWl0dGVkKQ0Kb3BlbmF0KEFUX0ZEQ1dELCAiL3N5
cy9rZXJuZWwvZGVidWcvZHJpLzAvYW1kZ3B1X2lvdmEiLCBPX1JEV1IpID0gLTEgDQpFTk9FTlQg
KE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkpDQpvcGVuYXQoQVRfRkRDV0QsICIvc3lzL2tlcm5l
bC9kZWJ1Zy9kcmkvMC9hbWRncHVfaW9tZW0iLCBPX1JEV1IpID0gLTEgDQpFUEVSTSAoT3BlcmF0
aW9uIG5vdCBwZXJtaXR0ZWQpDQpvcGVuYXQoQVRfRkRDV0QsICIvc3lzL2J1cy9wY2kvZGV2aWNl
cy8wMDAwOjBiOjAwLjAvdmJpb3NfdmVyc2lvbiIsIA0KT19SRE9OTFkpID0gMw0KZnN0YXQoMywg
e3N0X21vZGU9U19JRlJFR3wwNDQ0LCBzdF9zaXplPTQwOTYsIC4uLn0pID0gMA0KcmVhZCgzLCAi
eHh4LXh4eC14eHhcbiIsIDQwOTYpICAgICAgICAgID0gMTINCmNsb3NlKDMpICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICA9IDANCm9wZW5hdChBVF9GRENXRCwgIi9zeXMva2VybmVsL2Rl
YnVnL2RyaS8wL2FtZGdwdV9maXJtd2FyZV9pbmZvIiwgDQpPX1JET05MWSkgPSAzDQpmc3RhdCgz
LCB7c3RfbW9kZT1TX0lGUkVHfDA0NDQsIHN0X3NpemU9MCwgLi4ufSkgPSAwDQpyZWFkKDMsICJW
Q0UgZmVhdHVyZSB2ZXJzaW9uOiAwLCBmaXJtd2FyZSIuLi4sIDQwOTYpID0gMTA1OQ0KcmVhZCgz
LCAiIiwgNDA5NikgICAgICAgICAgICAgICAgICAgICAgID0gMA0KY2xvc2UoMykgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgID0gMA0Kb3BlbmF0KEFUX0ZEQ1dELCAiL3N5cy9rZXJuZWwv
ZGVidWcvZHJpLzAvYW1kZ3B1X2djYV9jb25maWciLCBPX1JET05MWSkgDQo9IC0xIEVQRVJNIChP
cGVyYXRpb24gbm90IHBlcm1pdHRlZCkNCm9wZW5hdChBVF9GRENXRCwgIi9zeXMva2VybmVsL2Rl
YnVnL2RyaS8wL2FtZGdwdV9yaW5nX2dmeCIsIE9fUkRXUikgPSAtMSANCkVQRVJNIChPcGVyYXRp
b24gbm90IHBlcm1pdHRlZCkNCg0KQXMgc3Vkby9yb290IHlvdSBzaG91bGQgYmUgYWJsZSB0byBv
cGVuIHRoZXNlIGZpbGVzIHdpdGggdW1yLiAgV2hhdCANCmhhcHBlbnMgaWYgeW91IGp1c3Qgb3Bl
biBhIHNoZWxsIGFzIHJvb3QgYW5kIHJ1biBpdD8NCg0KDQoNClRvbQ0K

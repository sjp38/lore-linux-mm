Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D186E6B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:11:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m6-v6so14586688pln.8
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:11:12 -0700 (PDT)
Received: from baidu.com ([220.181.50.185])
        by mx.google.com with ESMTP id t135si393966pgb.24.2018.03.26.23.11.10
        for <linux-mm@kvack.org>;
        Mon, 26 Mar 2018 23:11:11 -0700 (PDT)
From: "Li,Rongqing" <lirongqing@baidu.com>
Subject: =?gb2312?B?tPC4tDogtPC4tDogtPC4tDogtPC4tDogW1BBVENIXSBtbS9tZW1jb250cm9s?=
 =?gb2312?Q?.c:_speed_up_to_force_empty_a_memory_cgroup?=
Date: Tue, 27 Mar 2018 06:11:03 +0000
Message-ID: <2AD939572F25A448A3AE3CAEA61328C2375076CC@BC-MAIL-M28.internal.baidu.com>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <2AD939572F25A448A3AE3CAEA61328C2374832C1@BC-MAIL-M28.internal.baidu.com>
 <20180323100839.GO23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374EC73E@BC-MAIL-M28.internal.baidu.com>
 <20180323122902.GR23100@dhcp22.suse.cz>
In-Reply-To: <20180323122902.GR23100@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

DQoNCj4gLS0tLS3Tyrz+1K28/i0tLS0tDQo+ILeivP7IyzogbGludXgta2VybmVsLW93bmVyQHZn
ZXIua2VybmVsLm9yZw0KPiBbbWFpbHRvOmxpbnV4LWtlcm5lbC1vd25lckB2Z2VyLmtlcm5lbC5v
cmddILT6se0gTWljaGFsIEhvY2tvDQo+ILeiy83KsbzkOiAyMDE4xOoz1MIyM8jVIDIwOjI5DQo+
IMrVvP7IyzogTGksUm9uZ3FpbmcgPGxpcm9uZ3FpbmdAYmFpZHUuY29tPg0KPiCzrcvNOiBsaW51
eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+IGNncm91cHNA
dmdlci5rZXJuZWwub3JnOyBoYW5uZXNAY21weGNoZy5vcmc7IEFuZHJleSBSeWFiaW5pbg0KPiA8
YXJ5YWJpbmluQHZpcnR1b3p6by5jb20+DQo+INb3zOI6IFJlOiC08Li0OiC08Li0OiC08Li0OiBb
UEFUQ0hdIG1tL21lbWNvbnRyb2wuYzogc3BlZWQgdXAgdG8gZm9yY2UNCj4gZW1wdHkgYSBtZW1v
cnkgY2dyb3VwDQo+IA0KPiBPbiBGcmkgMjMtMDMtMTggMTI6MDQ6MTYsIExpLFJvbmdxaW5nIHdy
b3RlOg0KPiBbLi4uXQ0KPiA+IHNocmlua19zbGFiIGRvZXMgbm90IHJlY2xhaW0gYW55IG1lbW9y
eSwgYnV0IHRha2UgbG90cyBvZiB0aW1lIHRvDQo+ID4gY291bnQgbHJ1DQo+ID4NCj4gPiBtYXli
ZSB3ZSBjYW4gdXNlIHRoZSByZXR1cm5pbmcgb2Ygc2hyaW5rX3NsYWIgdG8gY29udHJvbCBpZiBu
ZXh0DQo+ID4gc2hyaW5rX3NsYWIgc2hvdWxkIGJlIGNhbGxlZD8NCj4gDQo+IEhvdz8gRGlmZmVy
ZW50IG1lbWNncyBtaWdodCBoYXZlIGRpZmZlcmVudCBhbW91bnQgb2Ygc2hyaW5rYWJsZSBtZW1v
cnkuDQo+IA0KDQptYXliZSB0aGVyZSBpcyBub3QgYSBlYXN5IHdheSB0byBpbXBsZW1lbnQgaXQN
Cg0KaW4gdGhpcyBjYXNlLCBzaHJpbmtfc2xhYiBjYWxsIG1hbnkgdGltZXMgbGlzdF9scnVfY291
bnRfb25lLCB3aGljaCBpcyBjYWxsaW5nIGxpc3RfbHJ1X2NvdW50X29uZSwgd2hpY2ggdXNlIHNw
aW5sb2NrLCBtYXliZSByZXBsYWNlIHNwaW5sb2NrIHdpdGggUkNVLCB0byBvcHRpbWl6ZQ0KDQoN
Ci1Sb25nUWluZw0KDQoNCj4gPiBPciBkZWZpbmUgYSBzbGlnaHQgbGlzdF9scnVfZW1wdHkgdG8g
Y2hlY2sgaWYgc2ItPnNfZGVudHJ5X2xydSBpcw0KPiA+IGVtcHR5IGJlZm9yZSBjYWxsaW5nIGxp
c3RfbHJ1X3Nocmlua19jb3VudCwgbGlrZSBiZWxvdw0KPiANCj4gRG9lcyBpdCByZWFsbHkgaGVs
cCB0byBpbXByb3ZlIG51bWJlcnM/DQo+IA0KPiA+IGRpZmYgLS1naXQgYS9mcy9zdXBlci5jIGIv
ZnMvc3VwZXIuYw0KPiA+IGluZGV4IDY3MjUzOGNhOTgzMS4uOTU0YzIyMzM4ODMzIDEwMDY0NA0K
PiA+IC0tLSBhL2ZzL3N1cGVyLmMNCj4gPiArKysgYi9mcy9zdXBlci5jDQo+ID4gQEAgLTEzMCw4
ICsxMzAsMTAgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgc3VwZXJfY2FjaGVfY291bnQoc3RydWN0
DQo+IHNocmlua2VyICpzaHJpbmssDQo+ID4gICAgICAgICBpZiAoc2ItPnNfb3AgJiYgc2ItPnNf
b3AtPm5yX2NhY2hlZF9vYmplY3RzKQ0KPiA+ICAgICAgICAgICAgICAgICB0b3RhbF9vYmplY3Rz
ID0gc2ItPnNfb3AtPm5yX2NhY2hlZF9vYmplY3RzKHNiLCBzYyk7DQo+ID4NCj4gPiAtICAgICAg
IHRvdGFsX29iamVjdHMgKz0gbGlzdF9scnVfc2hyaW5rX2NvdW50KCZzYi0+c19kZW50cnlfbHJ1
LCBzYyk7DQo+ID4gLSAgICAgICB0b3RhbF9vYmplY3RzICs9IGxpc3RfbHJ1X3Nocmlua19jb3Vu
dCgmc2ItPnNfaW5vZGVfbHJ1LCBzYyk7DQo+ID4gKyAgICAgICBpZiAoIWxpc3RfbHJ1X2VtcHR5
KHNiLT5zX2RlbnRyeV9scnUpKQ0KPiA+ICsgICAgICAgICAgICAgICB0b3RhbF9vYmplY3RzICs9
DQo+IGxpc3RfbHJ1X3Nocmlua19jb3VudCgmc2ItPnNfZGVudHJ5X2xydSwgc2MpOw0KPiA+ICsg
ICAgICAgaWYgKCFsaXN0X2xydV9lbXB0eShzYi0+c19pbm9kZV9scnUpKQ0KPiA+ICsgICAgICAg
ICAgICAgICB0b3RhbF9vYmplY3RzICs9DQo+ID4gKyBsaXN0X2xydV9zaHJpbmtfY291bnQoJnNi
LT5zX2lub2RlX2xydSwgc2MpOw0KPiA+DQo+ID4gICAgICAgICB0b3RhbF9vYmplY3RzID0gdmZz
X3ByZXNzdXJlX3JhdGlvKHRvdGFsX29iamVjdHMpOw0KPiA+ICAgICAgICAgcmV0dXJuIHRvdGFs
X29iamVjdHM7DQo+IA0KPiAtLQ0KPiBNaWNoYWwgSG9ja28NCj4gU1VTRSBMYWJzDQo=

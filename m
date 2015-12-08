Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4816C6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 18:53:15 -0500 (EST)
Received: by igl9 with SMTP id 9so107187888igl.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 15:53:15 -0800 (PST)
Received: from mgwym03.jp.fujitsu.com (mgwym03.jp.fujitsu.com. [211.128.242.42])
        by mx.google.com with ESMTPS id c18si10197398igr.94.2015.12.08.15.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 15:53:14 -0800 (PST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 0A84CAC005A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 08:53:06 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
Date: Tue, 8 Dec 2015 23:53:03 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54299215@G01JPEXMBYT01>
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<20151207163112.930a495d24ab259cad9020ac@linux-foundation.org>
	<E86EADE93E2D054CBCD4E708C38D364A54298EAE@G01JPEXMBYT01>
 <CA+8MBbJuYwT+PWu_Amy7RWxmNvuvG++Bn9ZL3kfbkz_rByqUKg@mail.gmail.com>
In-Reply-To: <CA+8MBbJuYwT+PWu_Amy7RWxmNvuvG++Bn9ZL3kfbkz_rByqUKg@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

RGVhciBUb255LA0KDQoNCj4gPiAgV2hpY2ggZG8geW91IHRoaW5rIGlzIGJl
dGVyID8NCj4gPiAgICAtIGNoYW5nZSBpbnRvIGtlcm5lbGNvcmU9Im1pcnJv
cmVkIg0KPiA+ICAgIC0ga2VlcCBrZXJuZWxjb3JlPSJyZWxpYWJsZSIgYW5k
IG1pbm1hbCBwcmludGsgZml4DQo+IA0KPiBVRUZJIGNhbWUgdXAgd2l0aCB0
aGUgInJlbGlhYmxlIiB3b3JkaW5nIChhcyBhIG1vcmUgZ2VuZXJpYyB0ZXJt
IC4uLg0KPiBhcyBBbmRyZXcgc2FpZA0KPiBpdCBjb3VsZCBjb3ZlciBkaWZm
ZXJlbmNlcyBpbiBFQ0MgbW9kZXMsIG9yIHNvbWUgYWx0ZXJuYXRlIG1lbW9y
eQ0KPiB0ZWNobm9sb2d5IHRoYXQNCj4gaGFzIGxvd2VyIGVycm9yIHJhdGVz
KS4NCj4gDQo+IEJ1dCBJIHBlcnNvbmFsbHkgbGlrZSAibWlycm9yIiBtb3Jl
IC4uLiBpdCBtYXRjaGVzIGN1cnJlbnQNCj4gaW1wbGVtZW50YXRpb24uIE9m
IGNvdXJzZQ0KPiBJJ2xsIGxvb2sgc2lsbHkgaWYgc29tZSBmdXR1cmUgc3lz
dGVtIGRvZXMgc29tZXRoaW5nIG90aGVyIHRoYW4gbWlycm9yLg0KPiANCg0K
IE9rYXksIEknbGwgY2hhbmdlIHRoZSBvcHRpb24gbmFtZSBpbnRvIGtlcm5l
bGNvcmU9bWlycm9yLg0KDQpTaW5jZXJlbHksDQpUYWt1IEl6dW1pDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

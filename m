Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7CE6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 01:41:57 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u143so179000810oif.1
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:41:57 -0800 (PST)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id q189si5615075oif.324.2017.01.22.22.41.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jan 2017 22:41:56 -0800 (PST)
From: zhouxianrong <zhouxianrong@huawei.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIXSBtbTogZXh0ZW5kIHplcm8gcGFnZXMgdG8gc2FtZSBl?=
 =?gb2312?Q?lement_pages_for_zram?=
Date: Mon, 23 Jan 2017 06:32:55 +0000
Message-ID: <AE94847B1D9E864B8593BD8051012AF36E0D8AC9@DGGEMA505-MBS.china.huawei.com>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123062621.GB12833@bombadil.infradead.org>
In-Reply-To: <20170123062621.GB12833@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "sergey.senozhatsky@gmail.com" <sergey.senozhatsky@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>, "ngupta@vflare.org" <ngupta@vflare.org>, Mi Sophia Wang <Mi.Sophia.Wang@huawei.com>, Zhouxiyu <zhouxiyu@huawei.com>, "Duwei (Device
 OS)" <weidu.du@huawei.com>, "Zhangshiming (Simon, Device OS)" <zhangshiming5@huawei.com>, Won Ho Park <won.ho.park@huawei.com>

WWVzLCBtZW1zZXQncyBwcm90b3R5cGUgaXMgaW50IGJ1dA0KdGhlIGltcGxlbWVudCBvZiBhcmNo
IGlzIHVuc2lnbmVkIGNoYXI7IGZvciBleGFtcGxlLCBpbiBhcm02NA0KDQoJLndlYWsgbWVtc2V0
DQpFTlRSWShfX21lbXNldCkNCkVOVFJZKG1lbXNldCkNCgltb3YJZHN0LCBkc3RpbgkvKiBQcmVz
ZXJ2ZSByZXR1cm4gdmFsdWUuICAqLw0KCWFuZAlBX2x3LCB2YWwsICMyNTUNCglvcnIJQV9sdywg
QV9sdywgQV9sdywgbHNsICM4DQoJb3JyCUFfbHcsIEFfbHcsIEFfbHcsIGxzbCAjMTYNCglvcnIJ
QV9sLCBBX2wsIEFfbCwgbHNsICMzMg0KDQotLS0tLdPKvP7Urbz+LS0tLS0NCreivP7IyzogTWF0
dGhldyBXaWxjb3ggW21haWx0bzp3aWxseUBpbmZyYWRlYWQub3JnXSANCreiy83KsbzkOiAyMDE3
xOox1MIyM8jVIDE0OjI2DQrK1bz+yMs6IHpob3V4aWFucm9uZw0Ks63LzTogU2VyZ2V5IFNlbm96
aGF0c2t5OyBsaW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7
IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IHNlcmdleS5zZW5vemhhdHNreUBnbWFpbC5jb207
IG1pbmNoYW5Aa2VybmVsLm9yZzsgbmd1cHRhQHZmbGFyZS5vcmc7IE1pIFNvcGhpYSBXYW5nOyBa
aG91eGl5dTsgRHV3ZWkgKERldmljZSBPUyk7IFpoYW5nc2hpbWluZyAoU2ltb24sIERldmljZSBP
Uyk7IFdvbiBIbyBQYXJrDQrW98ziOiBSZTogW1BBVENIXSBtbTogZXh0ZW5kIHplcm8gcGFnZXMg
dG8gc2FtZSBlbGVtZW50IHBhZ2VzIGZvciB6cmFtDQoNCk9uIFN1biwgSmFuIDIyLCAyMDE3IGF0
IDEwOjU4OjM4QU0gKzA4MDAsIHpob3V4aWFucm9uZyB3cm90ZToNCj4gMS4gbWVtc2V0IGlzIGp1
c3Qgc2V0IGEgaW50IHZhbHVlIGJ1dCBpIHdhbnQgdG8gc2V0IGEgbG9uZyB2YWx1ZS4NCg0KbWVt
c2V0IGRvZXNuJ3Qgc2V0IGFuIGludCB2YWx1ZS4NCg0KREVTQ1JJUFRJT04NCiAgICAgICBUaGUg
IG1lbXNldCgpICBmdW5jdGlvbiAgZmlsbHMgIHRoZSAgZmlyc3QgIG4gIGJ5dGVzIG9mIHRoZSBt
ZW1vcnkgYXJlYQ0KICAgICAgIHBvaW50ZWQgdG8gYnkgcyB3aXRoIHRoZSBjb25zdGFudCBieXRl
IGMuDQoNCkl0IHNldHMgYSBieXRlIHZhbHVlLiAgSyZSIGp1c3QgaGFwcGVuZWQgdG8gY2hvb3Nl
ICdpbnQnIGFzIHRoZSB0eXBlIHRvIHN0b3JlIHRoYXQgInVuc2lnbmVkIGNoYXIiIGluLiAgUHJv
YmFibHkgZm9yIHZlcnkgZ29vZCByZWFzb25zIHdoaWNoIG1ha2UgYWJzb2x1dGVseSBubyBzZW5z
ZSB0b2RheS4NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

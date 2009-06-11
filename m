Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0175D6B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 05:17:38 -0400 (EDT)
Received: by gxk28 with SMTP id 28so2127112gxk.14
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 02:18:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 11 Jun 2009 18:18:10 +0900
Message-ID: <28c262360906110218t6a3ed908g9a4fba7fa7dd7b22@mail.gmail.com>
Subject: Re: [PATCH 1/3] remove wrong rotation at lumpy reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBKdW4gMTEsIDIwMDkgYXQgNTowMCBQTSwgS0FNRVpBV0EKSGlyb3l1a2k8a2FtZXph
d2EuaGlyb3l1QGpwLmZ1aml0c3UuY29tPiB3cm90ZToKPiBGcm9tOiBLQU1FWkFXQSBIaXJveXVr
aSA8a2FtZXphd2EuaGlyb3l1QGpwLmZ1aml0c3UuY29tPgo+Cj4gQXQgbHVtcHkgcmVjbGFpbSwg
YSBwYWdlIGZhaWxlZCB0byBiZSB0YWtlbiBieSBfX2lzb2xhdGVfbHJ1X3BhZ2UoKSBjYW4KPiBi
ZSBwdXNoZWQgYmFjayB0byAic3JjIiBsaXN0IGJ5IGxpc3RfbW92ZSgpLiBCdXQgdGhlIHBhZ2Ug
bWF5IG5vdCBiZSBmcm9tCj4gInNyYyIgbGlzdC4gQW5kIGxpc3RfbW92ZSgpIGl0c2VsZiBpcyB1
bm5lY2Vzc2FyeSBiZWNhdXNlIHRoZSBwYWdlIGlzCj4gbm90IG9uIHRvcCBvZiBMUlUuIFRoZW4s
IGxlYXZlIGl0IGFzIGl0IGlzIGlmIF9faXNvbGF0ZV9scnVfcGFnZSgpIGZhaWxzLgo+Cj4gVGhp
cyBwYXRjaCBkb2Vzbid0IGNoYW5nZSB0aGUgbG9naWMgYXMgIndlIHNob3VsZCBleGl0IGxvb3Ag
b3Igbm90IiBhbmQKPiBqdXN0IGZpeGVzIGJ1Z2d5IGxpc3RfbW92ZSgpLgo+Cj4gU2lnbmVkLW9m
Zi1ieTogS0FNRVpBV0EgSGlyb3l1a2kgPGthbWV6YXdhLmhpcm95dUBqcC5mdWppdHN1LmNvbT4K
PiAtLS0KPiDCoG1tL3Ztc2Nhbi5jIHwgwqAgwqA5ICstLS0tLS0tLQo+IMKgMSBmaWxlIGNoYW5n
ZWQsIDEgaW5zZXJ0aW9uKCspLCA4IGRlbGV0aW9ucygtKQo+Cj4gSW5kZXg6IGx1bXB5LXJlY2xh
aW0tdHJpYWwvbW0vdm1zY2FuLmMKPiA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Cj4gLS0tIGx1bXB5LXJlY2xhaW0tdHJp
YWwub3JpZy9tbS92bXNjYW4uYwo+ICsrKyBsdW1weS1yZWNsYWltLXRyaWFsL21tL3Ztc2Nhbi5j
Cj4gQEAgLTkzNiwxOCArOTM2LDExIEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIGlzb2xhdGVfbHJ1
X3BhZ2VzKHUKPiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoC8qIENoZWNrIHRo
YXQgd2UgaGF2ZSBub3QgY3Jvc3NlZCBhIHpvbmUgYm91bmRhcnkuICovCj4gwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBpZiAodW5saWtlbHkocGFnZV96b25lX2lkKGN1cnNvcl9w
YWdlKSAhPSB6b25lX2lkKSkKPiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoGNvbnRpbnVlOwo+IC0gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
c3dpdGNoIChfX2lzb2xhdGVfbHJ1X3BhZ2UoY3Vyc29yX3BhZ2UsIG1vZGUsIGZpbGUpKSB7Cj4g
LSDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBjYXNlIDA6Cj4gKyDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpZiAoX19pc29sYXRlX2xydV9wYWdlKGN1cnNvcl9wYWdl
LCBtb2RlLCBmaWxlKSA9PSAwKSB7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqBsaXN0X21vdmUoJmN1cnNvcl9wYWdlLT5scnUsIGRzdCk7Cj4gwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBucl90YWtlbisrOwo+IMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgc2NhbisrOwo+IMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgYnJlYWs7CgpicmVh
ayA/PwoKLS0gCktpbmRzIHJlZ2FyZHMsCk1pbmNoYW4gS2ltCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

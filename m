Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B3FA6900007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 11:30:34 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v5 0/5] Add movablecore_map boot option
Date: Thu, 17 Jan 2013 16:30:31 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
 <50F440F5.3030006@zytor.com>
 <20130114143456.3962f3bd.akpm@linux-foundation.org>
 <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
 <20130114144601.1c40dc7e.akpm@linux-foundation.org>
 <50F647E8.509@jp.fujitsu.com>
 <20130116132953.6159b673.akpm@linux-foundation.org>
 <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>
 <50F79422.6090405@zytor.com>
In-Reply-To: <50F79422.6090405@zytor.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

PiAyLiBJZiB0aGUgdXNlciAqZG9lcyogY2FyZSB3aGljaCBub2RlcyBhcmUgbW92YWJsZSwgdGhl
biB0aGUgdXNlciBuZWVkcyANCj4gdG8gYmUgYWJsZSB0byBzcGVjaWZ5IHRoYXQgKmluIGEgd2F5
IHRoYXQgbWFrZXMgc2Vuc2UgdG8gdGhlIHVzZXIqLiANCj4gVGhpcyBtYXkgbWVhbiBpbnZvbHZp
bmcgdGhlIERNSSBpbmZvcm1hdGlvbiBhcyB3ZWxsIGFzIFNSQVQgaW4gb3JkZXIgdG8gDQo+IGdl
dCAic2lsayBzY3JlZW4iIHR5cGUgaW5mb3JtYXRpb24gb3V0Lg0KDQpPbmUgcmVhc29uIHRoZXkg
bWlnaHQgY2FyZSB3b3VsZCBiZSB3aGljaCBJL08gZGV2aWNlcyBhcmUgY29ubmVjdGVkDQp0byBl
YWNoIG5vZGUuICBETUkgbWlnaHQgYmUgYSBnb29kIHdheSB0byBnZXQgYW4gaW52YXJpYW50IG5h
bWUgZm9yIHRoZQ0Kbm9kZSwgYnV0IHRoZXkgbWlnaHQgYWxzbyB3YW50IHRvIHNwZWNpZnkgaW4g
dGVybXMgb2Ygd2hhdCB0aGV5IGFjdHVhbGx5DQp3YW50LiBFLmcuICJldGgwIGFuZCBldGg0IGFy
ZSBhIHJlZHVuZGFudCBib25kZWQgcGFpciBvZiBOSUNzIC0gZG9uJ3QNCm1hcmsgYm90aCB0aGVz
ZSBub2RlcyBhcyByZW1vdmFibGUiLiAgVGhvdWdoIHRoaXMgaXMgYWxtb3N0IGNlcnRhaW5seSBu
b3QNCmEgam9iIGZvciBrZXJuZWwgb3B0aW9ucywgYnV0IGZvciBzb21lIHVzZXIgY29uZmlndXJh
dGlvbiB0b29sIHRoYXQgd291bGQNCnNwaXQgb3V0IHRoZSBETUkgbmFtZXMuDQoNCi1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

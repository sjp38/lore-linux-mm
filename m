Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BC7566B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 13:29:20 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v5 0/5] Add movablecore_map boot option
Date: Fri, 18 Jan 2013 18:29:17 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
	 <50F440F5.3030006@zytor.com>
	 <20130114143456.3962f3bd.akpm@linux-foundation.org>
	 <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
	 <20130114144601.1c40dc7e.akpm@linux-foundation.org>
	 <50F647E8.509@jp.fujitsu.com>
	 <20130116132953.6159b673.akpm@linux-foundation.org>
	 <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>
	 <50F79422.6090405@zytor.com>
	 <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
	 <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com>
	 <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>
	 <50F8FBE9.6040501@jp.fujitsu.com>  <50F902F6.5010605@cn.fujitsu.com>
 <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com>
In-Reply-To: <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: li guang <lig.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

PiBrZXJuZWwgYWJzb2x1dGVseSBzaG91bGQgbm90IGNhcmUgbXVjaCBhYm91dCBTTUJJT1MoRE1J
IGluZm8pLA0KPiBBRkFJSywgZXZlcnkgQklPUyB2ZW5kb3IgZGlkIG5vdCBmaWxsIGFjY3VyYXRl
IGluZm8gaW4gU01CSU9TLA0KPiBtb3N0bHkgb25seSBvbiBkZW1hbmQgd2hlbiBPRU1zIHJlcXVp
cmVkIFNNQklPUyB0byByZXBvcnQgc29tZQ0KPiBzcGVjaWZpYyBpbmZvLg0KPiBmdXJ0aGVybW9y
ZSwgU01CSU9TIGlzIHNvIG9sZCBhbmQgYmVuaWZpdCBub2JvZHkoaW4gbXkgcGVyc29uYWwNCj4g
b3BpbmlvbiksIHNvIG1heWJlIGxldCdzIGZvcmdldCBpdC4NCg0KVGhlICJub3QgaGF2aW5nIHJp
Z2h0IGluZm9ybWF0aW9uIiBmbGF3IGNvdWxkIGJlIGZpeGVkIGJ5IE9FTXMgc2VsbGluZw0Kc3lz
dGVtcyBvbiB3aGljaCBpdCBpcyBpbXBvcnRhbnQgZm9yIHN5c3RlbSBmdW5jdGlvbmFsaXR5IHRo
YXQgaXQgYmUgcmlnaHQuDQpUaGV5IGNvdWxkIHVzZSBtb25ldGFyeSBpbmNlbnRpdmVzLCBjb250
cmFjdHVhbCBvYmxpZ2F0aW9ucywgb3Igc2hhcnANCnBvaW50eSBzdGlja3MgdG8gbWFrZSB0aGVp
ciBCSU9TIHZlbmRvciBnZXQgdGhlIHRhYmxlIHJpZ2h0Lg0KDQpCVVQgdGhlcmUgaXMgYSBiaWdn
ZXIgZmxhdyAtIFNNQklPUyBpcyBhIHN0YXRpYyB0YWJsZSB3aXRoIG5vIHdheSB0bw0KdXBkYXRl
IGl0IGluIHJlc3BvbnNlIHRvIGhvdHBsdWcgZXZlbnRzLiAgU28gaXQgY291bGQgaW4gdGhlb3J5
IGhhdmUgdGhlDQpyaWdodCBpbmZvcm1hdGlvbiBhdCBib290IHRpbWUgLi4uIHRoZXJlIGlzIG5v
IHBvc3NpYmxlIHdheSBmb3IgaXQgdG8gYmUNCnJpZ2h0IGFzIHNvb24gYXMgc29tZWJvZHkgYWRk
cywgcmVtb3ZlcyBvciByZXBsYWNlcyBoYXJkd2FyZS4NCg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

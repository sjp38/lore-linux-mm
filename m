Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id AE0616B004A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 18:43:10 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 2 Mar 2012 18:43:01 -0500
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB945618C@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <4F514E09.5060801@redhat.com>
In-Reply-To: <4F514E09.5060801@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

SGkgUmlrLA0KDQpUaGFuayB5b3UgZm9yIHJldmlld2luZy4NCg0KT24gMDMvMDIvMjAxMiAwNTo0
NyBQTSwgUmlrIHZhbiBSaWVsIHdyb3RlOg0KPiBPbiAwMy8wMi8yMDEyIDEyOjM2IFBNLCBTYXRv
cnUgTW9yaXlhIHdyb3RlOg0KPj4gQEAgLTE5OTksNyArMTk5OSw3IEBAIG91dDoNCj4+ICAgICAg
ICAgICB1bnNpZ25lZCBsb25nIHNjYW47DQo+Pg0KPj4gICAgICAgICAgIHNjYW4gPSB6b25lX25y
X2xydV9wYWdlcyhteiwgbHJ1KTsNCj4+IC0gICAgICAgIGlmIChwcmlvcml0eSB8fCBub3N3YXAp
IHsNCj4+ICsgICAgICAgIGlmIChwcmlvcml0eSB8fCBub3N3YXAgfHwgIXZtc2Nhbl9zd2FwcGlu
ZXNzKG16LCBzYykpIHsNCj4+ICAgICAgICAgICAgICAgc2Nhbj4+PSBwcmlvcml0eTsNCj4+ICAg
ICAgICAgICAgICAgaWYgKCFzY2FuJiYgIGZvcmNlX3NjYW4pDQo+PiAgICAgICAgICAgICAgICAg
ICBzY2FuID0gU1dBUF9DTFVTVEVSX01BWDsNCj4gDQo+IEhvd2V2ZXIsIEkgZG8gbm90IHVuZGVy
c3RhbmQgd2h5IHdlIGZhaWwgdG8gc2NhbGUgdGhlIG51bWJlciBvZiBwYWdlcyANCj4gd2Ugd2Fu
dCB0byBzY2FuIHdpdGggcHJpb3JpdHkgaWYgIm5vc3dhcCIuDQo+IA0KPiBGb3IgdGhhdCBtYXR0
ZXIsIHN1cmVseSBpZiB3ZSBkbyBub3Qgd2FudCB0byBzd2FwIG91dCBhbm9ueW1vdXMgcGFnZXMs
IA0KPiB3ZSBXQU5UIHRvIGdvIGludG8gdGhpcyBpZiBicmFuY2gsIGluIG9yZGVyIHRvIG1ha2Ug
c3VyZSB3ZSBzZXQgInNjYW4iIA0KPiB0byAwPw0KPiANCj4gc2NhbiA9IGRpdjY0X3U2NChzY2Fu
ICogZnJhY3Rpb25bZmlsZV0sIGRlbm9taW5hdG9yKTsNCj4gDQo+IFdpdGggeW91ciBwYXRjaCBh
bmQgc3dhcHBpbmVzcz0wLCBvciBubyBzd2FwIHNwYWNlLCBpdCBsb29rcyBsaWtlIHdlIA0KPiBk
byBub3QgemVybyBvdXQgInNjYW4iIGFuZCBtYXkgZW5kIHVwIHNjYW5uaW5nIGFub255bW91cyBw
YWdlcy4NCg0KV2l0aCBteSBwYXRjaCwgaWYgc3dhcHBpbmVzcz09MCBvciBub3N3YXA9PTEsIGZy
YWN0aW9uW2ZpbGVdIGlzDQpzZXQgdG8gMC4gQXMgYSByZXN1bHQsIHNjYW4gd2lsbCBiZSBzZXQg
dG8gMCwgdG9vLg0KDQo+IEFtIEkgb3Zlcmxvb2tpbmcgc29tZXRoaW5nPyAgSXMgdGhpcyBjb3Jy
ZWN0Pw0KPiANCj4gSSBtZWFuLCBpdCBpcyBGcmlkYXkgYW5kIG15IGJyYWluIGlzIHZlcnkgZnVs
bC4uLg0KDQpIYXZlIGEgbmljZSB3ZWVrZW5kIDspDQoNClJlZ2FyZHMsDQpTYXRvcnUNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

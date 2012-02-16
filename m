Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 374926B00E8
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:51:42 -0500 (EST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 10/11] nfs: Push file_update_time() into
 nfs_vm_page_mkwrite()
Date: Thu, 16 Feb 2012 13:50:19 +0000
Message-ID: <1329400219.2924.1.camel@lade.trondhjem.org>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
	 <1329399979-3647-11-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-11-git-send-email-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D8ABF0572E4E5541A2B4351FE359100D@tahoe.netapp.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>

T24gVGh1LCAyMDEyLTAyLTE2IGF0IDE0OjQ2ICswMTAwLCBKYW4gS2FyYSB3cm90ZToNCj4gQ0M6
IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQo+IENDOiBsaW51
eC1uZnNAdmdlci5rZXJuZWwub3JnDQo+IFNpZ25lZC1vZmYtYnk6IEphbiBLYXJhIDxqYWNrQHN1
c2UuY3o+DQo+IC0tLQ0KPiAgZnMvbmZzL2ZpbGUuYyB8ICAgIDMgKysrDQo+ICAxIGZpbGVzIGNo
YW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQg
YS9mcy9uZnMvZmlsZS5jIGIvZnMvbmZzL2ZpbGUuYw0KPiBpbmRleCBjNDNhNDUyLi4yNDA3OTIy
IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvZmlsZS5jDQo+ICsrKyBiL2ZzL25mcy9maWxlLmMNCj4g
QEAgLTUyNSw2ICs1MjUsOSBAQCBzdGF0aWMgaW50IG5mc192bV9wYWdlX21rd3JpdGUoc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9mYXVsdCAqdm1mKQ0KPiAgCS8qIG1ha2Ug
c3VyZSB0aGUgY2FjaGUgaGFzIGZpbmlzaGVkIHN0b3JpbmcgdGhlIHBhZ2UgKi8NCj4gIAluZnNf
ZnNjYWNoZV93YWl0X29uX3BhZ2Vfd3JpdGUoTkZTX0koZGVudHJ5LT5kX2lub2RlKSwgcGFnZSk7
DQo+ICANCj4gKwkvKiBVcGRhdGUgZmlsZSB0aW1lcyBiZWZvcmUgdGFraW5nIHBhZ2UgbG9jayAq
Lw0KPiArCWZpbGVfdXBkYXRlX3RpbWUoZmlscCk7DQo+ICsNCj4gIAlsb2NrX3BhZ2UocGFnZSk7
DQo+ICAJbWFwcGluZyA9IHBhZ2UtPm1hcHBpbmc7DQo+ICAJaWYgKG1hcHBpbmcgIT0gZGVudHJ5
LT5kX2lub2RlLT5pX21hcHBpbmcpDQoNCkhpIEphbiwNCg0KZmlsZV91cGRhdGVfdGltZSgpIGlz
IGEgbm8tb3AgaW4gTkZTLCBzaW5jZSB3ZSBzZXQgU19OT0FUSU1FfFNfTk9DTVRJTUUNCm9uIGFs
bCBpbm9kZXMuDQoNCkNoZWVycw0KICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFw
cC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

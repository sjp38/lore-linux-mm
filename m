Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 55A766B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 21:14:38 -0400 (EDT)
Received: by yhr47 with SMTP id 47so182675yhr.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:14:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F998FDE.5020104@redhat.com>
References: <4F998FDE.5020104@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 26 Apr 2012 21:14:16 -0400
Message-ID: <CAHGf_=qLX7gofwHoSKpHLp7nvD6qJtHbmYzAR0UQ42JbfnYerw@mail.gmail.com>
Subject: Re: [PATCH -mm V3] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

PiBAQCAtMTAxMiw2ICsxMDEyLDI2IEBAIGludCBkb19taWdyYXRlX3BhZ2VzKHN0cnVjdCBtbV9z
dHJ1Y3QgKm1tLAo+IKAgoCCgIKAgoCCgIKAgoGludCBkZXN0ID0gMDsKPgo+IKAgoCCgIKAgoCCg
IKAgoGZvcl9lYWNoX25vZGVfbWFzayhzLCB0bXApIHsKPiArCj4gKyCgIKAgoCCgIKAgoCCgIKAg
oCCgIKAgLyoKPiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgKiBkb19taWdyYXRlX3BhZ2VzKCkg
dHJpZXMgdG8gbWFpbnRhaW4gdGhlCj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCogcmVsYXRp
dmUgbm9kZSByZWxhdGlvbnNoaXAgb2YgdGhlIHBhZ2VzCj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCg
IKAgoCogZXN0YWJsaXNoZWQgYmV0d2VlbiB0aHJlYWRzIGFuZCBtZW1vcnkgYXJlYXMuCj4gKyCg
IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCoKPiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgKiBIb3dl
dmVyIGlmIHRoZSBudW1iZXIgb2Ygc291cmNlIG5vZGVzIGlzIG5vdAo+ICsgoCCgIKAgoCCgIKAg
oCCgIKAgoCCgIKAqIGVxdWFsIHRvIHRoZSBudW1iZXIgb2YgZGVzdGluYXRpb24gbm9kZXMgd2UK
PiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgKiBjYW4gbm90IHByZXNlcnZlIHRoaXMgbm9kZSBy
ZWxhdGl2ZSByZWxhdGlvbnNoaXAuCj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCogSW4gdGhh
dCBjYXNlLCBza2lwIGNvcHlpbmcgbWVtb3J5IGZyb20gYSBub2RlCj4gdGhhdAo+ICsgoCCgIKAg
oCCgIKAgoCCgIKAgoCCgIKAqIGlzIGluIHRoZSBkZXN0aW5hdGlvbiBtYXNrLgo+ICsgoCCgIKAg
oCCgIKAgoCCgIKAgoCCgIKAqCj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCogRXhhbXBsZTog
WzIsMyw0XSAtPiBbMyw0LDVdIG1vdmVzIGV2ZXJ5dGhpbmcuCj4gKyCgIKAgoCCgIKAgoCCgIKAg
oCCgIKAgoCogoCCgIKAgoCCgIKAgoCCgIFswLTddIC0gPiBbMyw0LDVdIG1vdmVzIG9ubHkKPiAw
LDEsMiw2LDcuCj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCovCj4gKwo+ICsgoCCgIKAgoCCg
IKAgoCCgIKAgoCCgIGlmICgobm9kZXNfd2VpZ2h0KCpmcm9tX25vZGVzKSAhPQo+IG5vZGVzX3dl
aWdodCgqdG9fbm9kZXMpKSAmJgo+ICsgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCg
IKAgoCCgIKAgoCCgIChub2RlX2lzc2V0KHMsICp0b19ub2RlcykpKQo+ICsgoCCgIKAgoCCgIKAg
oCCgIKAgoCCgIKAgoCCgIKAgY29udGludWU7Cj4gKwo+IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCg
ZCA9IG5vZGVfcmVtYXAocywgKmZyb21fbm9kZXMsICp0b19ub2Rlcyk7Cj4goCCgIKAgoCCgIKAg
oCCgIKAgoCCgIKBpZiAocyA9PSBkKQo+IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKBj
b250aW51ZTsKCkFja2VkLWJ5OiBLT1NBS0kgTW90b2hpcm8gPGtvc2FraS5tb3RvaGlyb0BqcC5m
dWppdHN1LmNvbT4K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

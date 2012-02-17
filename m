Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 660566B007E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:06:19 -0500 (EST)
Received: by vbip1 with SMTP id p1so3231987vbi.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 05:06:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120216151425.GB19158@phenom.ffwll.local>
References: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
	<1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
	<CAJd=RBBr4EkCwAaS3xZZrm0QE71Z0soyZXTuwXyBn6ohp3pU2Q@mail.gmail.com>
	<20120216151425.GB19158@phenom.ffwll.local>
Date: Fri, 17 Feb 2012 21:06:17 +0800
Message-ID: <CAJd=RBDFUZi3_tk2ZRpjF=5a9884zJGv4Ti_kM0pjXnRmw0jKA@mail.gmail.com>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than PAGE_SIZE
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>

T24gVGh1LCBGZWIgMTYsIDIwMTIgYXQgMTE6MTQgUE0sIERhbmllbCBWZXR0ZXIgPGRhbmllbEBm
ZndsbC5jaD4gd3JvdGU6Cj4gT24gVGh1LCBGZWIgMTYsIDIwMTIgYXQgMDk6MzI6MDhQTSArMDgw
MCwgSGlsbGYgRGFudG9uIHdyb3RlOgo+PiBPbiBUaHUsIEZlYiAxNiwgMjAxMiBhdCA4OjAxIFBN
LCBEYW5pZWwgVmV0dGVyIDxkYW5pZWwudmV0dGVyQGZmd2xsLmNoPiB3cm90ZToKPj4gPiBAQCAt
NDE2LDE3ICs0MTcsMjAgQEAgc3RhdGljIGlubGluZSBpbnQgZmF1bHRfaW5fcGFnZXNfd3JpdGVh
YmxlKGNoYXIgX191c2VyICp1YWRkciwgaW50IHNpemUpCj4+ID4gwqAgwqAgwqAgwqAgKiBXcml0
aW5nIHplcm9lcyBpbnRvIHVzZXJzcGFjZSBoZXJlIGlzIE9LLCBiZWNhdXNlIHdlIGtub3cgdGhh
dCBpZgo+PiA+IMKgIMKgIMKgIMKgICogdGhlIHplcm8gZ2V0cyB0aGVyZSwgd2UnbGwgYmUgb3Zl
cndyaXRpbmcgaXQuCj4+ID4gwqAgwqAgwqAgwqAgKi8KPj4gPiAtIMKgIMKgIMKgIHJldCA9IF9f
cHV0X3VzZXIoMCwgdWFkZHIpOwo+PiA+ICsgwqAgwqAgwqAgd2hpbGUgKHVhZGRyIDw9IGVuZCkg
ewo+PiA+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgcmV0ID0gX19wdXRfdXNlcigwLCB1YWRkcik7
Cj4+ID4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpZiAocmV0ICE9IDApCj4+ID4gKyDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gcmV0Owo+PiA+ICsgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgdWFkZHIgKz0gUEFHRV9TSVpFOwo+PiA+ICsgwqAgwqAgwqAgfQo+Pgo+PiBXaGF0
IGlmCj4+IMKgIMKgIMKgIMKgIMKgIMKgIMKgdWFkZHIgJiB+UEFHRV9NQVNLID09IFBBR0VfU0la
RSAtMyAmJgo+PiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBlbmQgJiB+UEFHRV9NQVNLID09IDIK
Pgo+IEkgZG9uJ3QgcXVpdGUgZm9sbG93IC0gY2FuIHlvdSBlbGFib3JhdGUgdXBvbiB3aGljaCBp
c3N1ZSB5b3UncmUgc2VlaW5nPwoKSSBjb25jZXJuZWQgdGhhdCBfX3B1dF91c2VyKDAsIGVuZCkg
aXMgbWlzc2VkLCBidXQgaXQgd2FzIGFkZGVkIGJlbG93LgoKQW5kIGxvb2tzIGdvb2QgdG8gbWUu
CkhpbGxmCgo+IMKgIMKgIMKgIMKgaWYgKHJldCA9PSAwKSB7Cj4gLSDCoCDCoCDCoCDCoCDCoCDC
oCDCoCBjaGFyIF9fdXNlciAqZW5kID0gdWFkZHIgKyBzaXplIC0gMTsKPiAtCj4gwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAvKgo+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgICogSWYgdGhlIHBhZ2Ug
d2FzIGFscmVhZHkgbWFwcGVkLCB0aGlzIHdpbGwgZ2V0IGEgY2FjaGUgbWlzcwo+IMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgICogZm9yIHN1cmUsIHNvIHRyeSB0byBhdm9pZCBkb2luZyBpdC4KPiDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCAqLwo+IC0gwqAgwqAgwqAgwqAgwqAgwqAgwqAgaWYgKCgo
dW5zaWduZWQgbG9uZyl1YWRkciAmIFBBR0VfTUFTSykgIT0KPiArIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIGlmICgoKHVuc2lnbmVkIGxvbmcpdWFkZHIgJiBQQUdFX01BU0spID09Cj4gwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAoKHVuc2lnbmVkIGxvbmcpZW5k
ICYgUEFHRV9NQVNLKSkKPiAtIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHJldCA9
IF9fcHV0X3VzZXIoMCwgZW5kKTsKPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHJldCA9IF9fcHV0X3VzZXIoMCwgZW5kKTsKPiDCoCDCoCDCoCDCoH0KPiDCoCDCoCDCoCDCoHJl
dHVybiByZXQ7Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6DB56B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 18:32:36 -0500 (EST)
Received: by yenm10 with SMTP id m10so1183818yen.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:32:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111123957.7371.72792.stgit@zurg>
References: <20110729075837.12274.58405.stgit@localhost6>
	<20111111123957.7371.72792.stgit@zurg>
Date: Sat, 12 Nov 2011 08:32:33 +0900
Message-ID: <CAEwNFnA_ZGRyrtZ_LRzz66hmes8r+g+JEHHRAKsKWci7He-+5A@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] mm: add free_hot_cold_page_list helper
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

T24gRnJpLCBOb3YgMTEsIDIwMTEgYXQgMTA6MzkgUE0sIEtvbnN0YW50aW4gS2hsZWJuaWtvdgo8
a2hsZWJuaWtvdkBvcGVudnoub3JnPiB3cm90ZToKPiBUaGlzIHBhdGNoIGFkZHMgaGVscGVyIGZy
ZWVfaG90X2NvbGRfcGFnZV9saXN0KCkgdG8gZnJlZSBsaXN0IG9mIDAtb3JkZXIgcGFnZXMuCj4g
SXQgZnJlZXMgcGFnZXMgZGlyZWN0bHkgZnJvbSB0aGUgbGlzdCB3aXRob3V0IHRlbXBvcmFyeSBw
YWdlLXZlY3Rvci4KPiBJdCBhbHNvIGNhbGxzIHRyYWNlX21tX3BhZ2V2ZWNfZnJlZSgpIHRvIHNp
bXVsYXRlIHBhZ2V2ZWNfZnJlZSgpIGJlaGF2aW91ci4KPgo+IGJsb2F0LW8tbWV0ZXI6Cj4KPiBh
ZGQvcmVtb3ZlOiAxLzEgZ3Jvdy9zaHJpbms6IDEvMyB1cC9kb3duOiAyNjcvLTI5NSAoLTI4KQo+
IGZ1bmN0aW9uIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIG9sZCDCoCDCoCBuZXcgwqAgZGVsdGEKPiBmcmVlX2hvdF9jb2xkX3BhZ2VfbGlzdCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoC0gwqAgwqAgMjY0IMKgIMKgKzI2NAo+
IGdldF9wYWdlX2Zyb21fZnJlZWxpc3QgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAy
MTI5IMKgIMKgMjEzMiDCoCDCoCDCoCszCj4gX19wYWdldmVjX2ZyZWUgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgMjQzIMKgIMKgIDIzOSDCoCDCoCDCoC00Cj4g
c3BsaXRfZnJlZV9wYWdlIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgMzgwIMKgIMKgIDM3MyDCoCDCoCDCoC03Cj4gcmVsZWFzZV9wYWdlcyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoDYwNiDCoCDCoCA1MTAgwqAgwqAgLTk2
Cj4gZnJlZV9wYWdlX2xpc3QgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgMTg4IMKgIMKgIMKgIC0gwqAgwqAtMTg4Cj4KPiB2MjogUmVtb3ZlIGxpc3QgcmVpbml0
aXRpYWxpemF0aW9uLgo+IHYzOiBBbHdheXMgZnJlZSBwYWdlcyBpbiByZXZlcnNlIG9yZGVyLgo+
IMKgIMKgVGhlIG1vc3QgcmVjZW50bHkgYWRkZWQgc3RydWN0IHBhZ2UsIHRoZSBtb3N0IGxpa2Vs
eSB0byBiZSBob3QuCj4KPiBTaWduZWQtb2ZmLWJ5OiBLb25zdGFudGluIEtobGVibmlrb3YgPGto
bGVibmlrb3ZAb3BlbnZ6Lm9yZz4KUmV2aWV3ZWQtYnk6IE1pbmNoYW4gS2ltIDxtaW5jaGFuLmtp
bUBnbWFpbC5jb20+CgotLSAKS2luZCByZWdhcmRzLApNaW5jaGFuIEtpbQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

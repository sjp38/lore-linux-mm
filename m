Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 137592808C1
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:16:29 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 9so140596072qkk.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:16:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r65si5741720qtd.128.2017.03.09.06.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 06:16:28 -0800 (PST)
Message-ID: <1489068985.1906.1.camel@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Rik van Riel <riel@redhat.com>
Date: Thu, 09 Mar 2017 09:16:25 -0500
In-Reply-To: <20170309091224.GC11592@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
	 <1488916356.6405.4.camel@redhat.com>
	 <20170308092114.GB11028@dhcp22.suse.cz>
	 <1488988497.8850.23.camel@redhat.com>
	 <20170309091224.GC11592@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-UrKpr+r+c7n/AacDTC8q"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--=-UrKpr+r+c7n/AacDTC8q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

T24gVGh1LCAyMDE3LTAzLTA5IGF0IDEwOjEyICswMTAwLCBNaWNoYWwgSG9ja28gd3JvdGU6Cj4g
T24gV2VkIDA4LTAzLTE3IDEwOjU0OjU3LCBSaWsgdmFuIFJpZWwgd3JvdGU6Cgo+ID4gSW4gZmFj
dCwgZmFsc2UgT09NIGtpbGxzIHdpdGggdGhhdCBraW5kIG9mIHdvcmtsb2FkIGlzCj4gPiBob3cg
d2UgZW5kZWQgdXAgZ2V0dGluZyB0aGUgInRvbyBtYW55IGlzb2xhdGVkIiBsb2dpYwo+ID4gaW4g
dGhlIGZpcnN0IHBsYWNlLgo+IFJpZ2h0LCBidXQgdGhlIHJldHJ5IGxvZ2ljIHdhcyBjb25zaWRl
cmFibHkgZGlmZmVyZW50IHRoYW4gd2hhdCB3ZQo+IGhhdmUgdGhlc2UgZGF5cy4gc2hvdWxkX3Jl
Y2xhaW1fcmV0cnkgY29uc2lkZXJzIGFtb3VudCBvZiByZWNsYWltYWJsZQo+IG1lbW9yeS4gQXMg
SSd2ZSBzYWlkIGVhcmxpZXIgaWYgd2Ugc2VlIGEgcmVwb3J0IHdoZXJlIHRoZSBvb20gaGl0cwo+
IHByZW1hdHVyZWx5IHdpdGggbWFueSBOUl9JU09MQVRFRCogd2Uga25vdyBob3cgdG8gZml4IHRo
YXQuCgpXb3VsZCBpdCBiZSBlbm91Z2ggdG8gc2ltcGx5IHJlc2V0IG5vX3Byb2dyZXNzX2xvb3Bz
CmluIHRoaXMgY2hlY2sgaW5zaWRlIHNob3VsZF9yZWNsYWltX3JldHJ5LCBpZiB3ZSBrbm93CnBh
Z2VvdXQgSU8gaXMgcGVuZGluZz8KCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IGlmICghZGlkX3NvbWVfcHJvZ3Jlc3MpIHsKwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHVuc2lnbmVkIGxvbmcgd3JpdGVfcGVu
ZGluZzsKCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqB3cml0ZV9wZW5kaW5nID0Kem9uZV9wYWdlX3N0YXRlX3NuYXBzaG90KHpv
bmUsCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqBOUl9aT05FX1dSSVRFX1AKRU5ESU5HKTsKCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBpZiAoMiAqIHdyaXRlX3BlbmRpbmcg
PiByZWNsYWltYWJsZSkgewrCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGNvbmdlc3Rpb25fd2FpdChC
TEtfUldfQVNZTkMsCkhaLzEwKTsKwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqByZXR1cm4gdHJ1ZTsK
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoH0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
fQoKLS0gCkFsbCByaWdodHMgcmV2ZXJzZWQK


--=-UrKpr+r+c7n/AacDTC8q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYwWO5AAoJEM553pKExN6DaUUH/0l9hxdt0uEmWZNU9K2kw2Sa
+HN6zxblM+mwLYM31DJ8MXnQXsdnzY/AwZatwNG7km9fhLrBuGQj0m4Y7HUXufNY
Y06/QfQJ+e5sfMTC7INfkMNh0MxJMkSkA0/fE28UTVQRXatzEOQz7aywV380HAnZ
dWnDEJsckbDEqRKrhHBLOY9eC1wja6ySp/q+PtNiL2ivRaOaiVNKskFyZy0ypNHS
hGNTuJp2tE6kdggO5DASOiDcIoYF0mrTQ6Iu8U+x9Mahqm13h0U7m/UwpN/hIWEh
AG9agw3xEEYk9hxgaqDuyl8JwArLmbdDxSpj5Yxt3BfV5asFBwbmgW6U4rhRaJ0=
=LAv9
-----END PGP SIGNATURE-----

--=-UrKpr+r+c7n/AacDTC8q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

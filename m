Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F830C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:57:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48C80206BF
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:57:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48C80206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7FF76B0006; Tue, 27 Aug 2019 19:57:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C309B6B0008; Tue, 27 Aug 2019 19:57:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF9226B000A; Tue, 27 Aug 2019 19:57:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF226B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:57:18 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1DD98181AC9AE
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:57:18 +0000 (UTC)
X-FDA: 75869871756.27.boy12_2289f92dfc439
X-HE-Tag: boy12_2289f92dfc439
X-Filterd-Recvd-Size: 4642
Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:57:17 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Aug 2019 16:57:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,439,1559545200"; 
   d="scan'208";a="192412679"
Received: from orsmsx105.amr.corp.intel.com ([10.22.225.132])
  by orsmga002.jf.intel.com with ESMTP; 27 Aug 2019 16:57:14 -0700
Received: from orsmsx121.amr.corp.intel.com ([169.254.10.57]) by
 ORSMSX105.amr.corp.intel.com ([169.254.2.66]) with mapi id 14.03.0439.000;
 Tue, 27 Aug 2019 16:57:14 -0700
From: "Keppel, Pardo" <pardo.keppel@intel.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mtk.manpages@gmail.com"
	<mtk.manpages@gmail.com>
CC: "Hansen, Dave" <dave.hansen@intel.com>, "Keppel, Pardo"
	<pardo.keppel@intel.com>
Subject: [patch] mremap.2: Note/clarify "partial completion" on errors
Thread-Topic: [patch] mremap.2: Note/clarify "partial completion" on errors
Thread-Index: AdVdMnrV5boX8JSFS+iVGVEVCto0vw==
Date: Tue, 27 Aug 2019 23:57:13 +0000
Message-ID: <388C0EB820381246B2BFD2C7583B3ECBAA1EE1FA@ORSMSX121.amr.corp.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMGIwZDRkNDMtNmRlYy00YTE1LWEyNGUtZGE2ZWFiMDM0YTljIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiRVlOTW5pWnUzWXRLUEIxMVpTdTlVbGEydnpoS3JRZkRsQlwvR1hxZGN2MkZDMDIrKzJ5eFNoOU5vMVlqMTUyZ3EifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
dlp-reaction: no-action
x-originating-ip: [10.22.254.138]
Content-Type: multipart/mixed;
	boundary="_002_388C0EB820381246B2BFD2C7583B3ECBAA1EE1FAORSMSX121amrcor_"
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_002_388C0EB820381246B2BFD2C7583B3ECBAA1EE1FAORSMSX121amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

When using mremap() with MREMAP_FIXED and bad parameters, mremap()
returns EINVAL, which is expected; but it also unmaps existing regions
at 'new_address', which surprised me.  I had expected that on EINVAL,
mappings at 'new_address' would remain unmodified.

The current behavior is reasonable, but it was surprising to me, so it migh=
t
be surprising to others.  The man page DESCRIPTION currently says:

    "Any previous mapping at the address range specified by new_address
    and new_size is unmapped."

It would be clearer to me if it also said something like:

   "Previous mappings may be unmapped even if mremap() returns an error."

And/or if ERRORS said something about this behavior.

A sample patch for man2/mremap.2 is attached.

--_002_388C0EB820381246B2BFD2C7583B3ECBAA1EE1FAORSMSX121amrcor_
Content-Type: application/octet-stream; name="mremap.2.patch"
Content-Description: mremap.2.patch
Content-Disposition: attachment; filename="mremap.2.patch"; size=788;
	creation-date="Tue, 27 Aug 2019 21:18:19 GMT";
	modification-date="Tue, 27 Aug 2019 21:43:38 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL21hbjIvbXJlbWFwLjIgYi9tYW4yL21yZW1hcC4yCmluZGV4IGQ3M2ZiNjRm
YS4uZjY0MDhhNWM5IDEwMDY0NAotLS0gYS9tYW4yL21yZW1hcC4yCisrKyBiL21hbjIvbXJlbWFw
LjIKQEAgLTEyNCw2ICsxMjQsOSBAQCBBbnkgcHJldmlvdXMgbWFwcGluZyBhdCB0aGUgYWRkcmVz
cyByYW5nZSBzcGVjaWZpZWQgYnkKIGFuZAogLkkgbmV3X3NpemUKIGlzIHVubWFwcGVkLgorUHJl
dmlvdXMgbWFwcGluZ3MgbWF5IGJlIHVubWFwcGVkIGV2ZW4gaWYKKy5CUiBtcmVtYXAgKCkKK3Jl
dHVybnMgYW4gZXJyb3IuCiBJZgogLkIgTVJFTUFQX0ZJWEVECiBpcyBzcGVjaWZpZWQsIHRoZW4K
QEAgLTE0OCw2ICsxNTEsMTYgQEAgT24gZXJyb3IsIHRoZSB2YWx1ZQogKHRoYXQgaXMsIFxmSSh2
b2lkXCAqKVwgXC0xXGZQKSBpcyByZXR1cm5lZCwKIGFuZCBcZkllcnJub1xmUCBpcyBzZXQgYXBw
cm9wcmlhdGVseS4KIC5TSCBFUlJPUlMKK09uIGVycm9ycywKKy5CUiBtcmVtYXAgKCkKK21heSBw
ZXJmb3JtCisuSSBwYXJ0aWFsIGNvbXBsZXRpb24KK3doZXJlIHNvbWUgYnV0IG5vdCBhbGwgc2lk
ZS1lZmZlY3RzIG9jY3VyLgorRm9yIGV4YW1wbGUsIHdpdGgKKy5CUiBNUkVNQVBfRklYRUQgLAor
bWFwcGluZ3MgYXQKKy5CIG5ld19hZGRyZXNzCittYXkgYmUgdW5tYXBwZWQsIHdpdGggbm8gbmV3
IG1hcHBpbmdzIHRvIHJlcGxhY2UgdGhlbS4KIC5UUAogLkIgRUFHQUlOCiBUaGUgY2FsbGVyIHRy
aWVkIHRvIGV4cGFuZCBhIG1lbW9yeSBzZWdtZW50IHRoYXQgaXMgbG9ja2VkLAo=

--_002_388C0EB820381246B2BFD2C7583B3ECBAA1EE1FAORSMSX121amrcor_--


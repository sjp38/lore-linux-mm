Received: by wf-out-1314.google.com with SMTP id 25so5776643wfc.11
        for <linux-mm@kvack.org>; Mon, 17 Mar 2008 01:10:31 -0700 (PDT)
Message-ID: <86802c440803170110l2e47c25bu2adb16b094d2867f@mail.gmail.com>
Date: Mon, 17 Mar 2008 01:10:31 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
In-Reply-To: <86802c440803170053n32a1c918h2ff2a32abef44050@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_16162_26021772.1205741431225"
References: <20080317258.659191058@firstfloor.org>
	 <20080317015825.0C0171B41E0@basil.firstfloor.org>
	 <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
	 <20080317070208.GC27015@one.firstfloor.org>
	 <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com>
	 <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com>
	 <20080317074146.GG27015@one.firstfloor.org>
	 <86802c440803170053n32a1c918h2ff2a32abef44050@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

------=_Part_16162_26021772.1205741431225
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

please check the one against -mm and x86.git

---

------=_Part_16162_26021772.1205741431225
Content-Type: text/x-patch; name=offset_alloc_bootmem.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fdwrbn060
Content-Disposition: attachment; filename=offset_alloc_bootmem.patch

RnJvbTogQW5kaSBLbGVlbiA8YWtAc3VzZS5kZT4KCltQQVRDSF0gbW06IG9mZnNldCBhbGlnbiBp
biBhbGxvY19ib290bWVtCgpuZWVkIG9mZnNldCBhbGlnbm1lbnQgd2hlbiBub2RlX2Jvb3Rfc3Rh
cnQncyBhbGlnbm1lbnQgaXMgbGVzcyB0aGFuCmFsaWduIHJlcXVpcmVkCgpJbmRleDogbGludXgt
Mi42L21tL2Jvb3RtZW0uYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9tbS9ib290bWVt
LmMKKysrIGxpbnV4LTIuNi9tbS9ib290bWVtLmMKQEAgLTI1Nyw3ICsyNTcsNyBAQCByZXN0YXJ0
X3NjYW46CiAJCXVuc2lnbmVkIGxvbmcgajsKIAogCQlpID0gZmluZF9uZXh0X3plcm9fYml0KGJk
YXRhLT5ub2RlX2Jvb3RtZW1fbWFwLCBlaWR4LCBpKTsKLQkJaSA9IEFMSUdOKGksIGluY3IpOwor
CQlpID0gQUxJR04oaSArIG9mZnNldCwgaW5jcikgLSBvZmZzZXQ7CiAJCWlmIChpID49IGVpZHgp
CiAJCQlicmVhazsKIAkJaWYgKHRlc3RfYml0KGksIGJkYXRhLT5ub2RlX2Jvb3RtZW1fbWFwKSkg
ewpAQCAtMjczLDcgKzI3Myw3IEBAIHJlc3RhcnRfc2NhbjoKIAkJc3RhcnQgPSBpOwogCQlnb3Rv
IGZvdW5kOwogCWZhaWxfYmxvY2s6Ci0JCWkgPSBBTElHTihqLCBpbmNyKTsKKwkJaSA9IEFMSUdO
KGogKyBvZmZzZXQsIGluY3IpIC0gb2Zmc2V0OwogCQlpZiAoaSA9PSBqKQogCQkJaSArPSBpbmNy
OwogCX0K
------=_Part_16162_26021772.1205741431225--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

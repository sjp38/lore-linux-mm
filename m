Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id BF8546B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 17:19:58 -0400 (EDT)
Received: by mail-ia0-f174.google.com with SMTP id b35so1622680iac.5
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 14:19:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <514767A5.4020601@zytor.com>
References: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com>
	<CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com>
	<51476402.7050102@zytor.com>
	<CAE9FiQUZDqqeAp2y=Pc9yFT81Pf+ei2SEx4NUD6jC+nQmd6PcA@mail.gmail.com>
	<514767A5.4020601@zytor.com>
Date: Mon, 18 Mar 2013 14:19:57 -0700
Message-ID: <CAE9FiQU2iqx=9LEx_u6J5O_kQ-5Lo6DTgSgnk71k0p6WWUa7Hg@mail.gmail.com>
Subject: Re: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=14dae93410eb0ba37104d8398df5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, penberg@kernel.org, jacob.shin@amd.com

--14dae93410eb0ba37104d8398df5
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Mar 18, 2013 at 12:14 PM, H. Peter Anvin <hpa@zytor.com> wrote:

> Instead, try to explain why 5 is the correct value in the current code
> and how it is (or should be!) derived.

initial mapped size is PMD_SIZE, aka 2M.
if we use step_size to be PUD_SIZE aka 1G, as most worse case
that 1G is cross the 1G boundary, and PG_LEVEL_2M is not set,
we will need 1+1+512 pages (aka 2M + 8k) to map 1G range with PTE.
So i picked (30-21)/2 to get 5.

Please check attached patch.

Thanks

Yinghai

--14dae93410eb0ba37104d8398df5
Content-Type: application/octet-stream;
	name="add_comment_for_step_size.patch"
Content-Disposition: attachment; filename="add_comment_for_step_size.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heg4x0er0

U3ViamVjdDogW1BBVENIXSB4ODYsIG1tOiBBZGQgY29tbWVudHMgZm9yIHN0ZXBfc2l6ZSBzaGlm
dAoKQXMgcmVxdWVzdCBieSBocGEsIGFkZCBjb21tZW50cyBmb3Igd2h5IHdlIGNob29zZSA1IGZv
cgpzdGVwIHNpemUgc2hpZnQuCgpTaWduZWQtb2ZmLWJ5OiBZaW5naGFpIEx1IDx5aW5naGFpQGtl
cm5lbC5vcmc+CgotLS0KIGFyY2gveDg2L21tL2luaXQuYyB8ICAgMjEgKysrKysrKysrKysrKysr
KysrLS0tCiAxIGZpbGUgY2hhbmdlZCwgMTggaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkK
CkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYvbW0vaW5pdC5jCj09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxpbnV4
LTIuNi5vcmlnL2FyY2gveDg2L21tL2luaXQuYworKysgbGludXgtMi42L2FyY2gveDg2L21tL2lu
aXQuYwpAQCAtMzg5LDggKzM4OSwyMyBAQCBzdGF0aWMgdW5zaWduZWQgbG9uZyBfX2luaXQgaW5p
dF9yYW5nZV9tCiAJcmV0dXJuIG1hcHBlZF9yYW1fc2l6ZTsKIH0KIAotLyogKFBVRF9TSElGVC1Q
TURfU0hJRlQpLzIgKi8KLSNkZWZpbmUgU1RFUF9TSVpFX1NISUZUIDUKK3N0YXRpYyB1bnNpZ25l
ZCBsb25nIF9faW5pdCBnZXRfbmV3X3N0ZXBfc2l6ZSh1bnNpZ25lZCBsb25nIHN0ZXBfc2l6ZSkK
K3sKKwkvKgorCSAqIGluaXRpYWwgbWFwcGVkIHNpemUgaXMgUE1EX1NJWkUsIGFrYSAyTS4KKwkg
KiBXZSBjYW4gbm90IHNldCBzdGVwX3NpemUgdG8gYmUgUFVEX1NJWkUgYWthIDFHIHlldC4KKwkg
KiBJbiB3b3JzZSBjYXNlLCB3aGVuIDFHIGlzIGNyb3NzIHRoZSAxRyBib3VuZGFyeSwgYW5kCisJ
ICogUEdfTEVWRUxfMk0gaXMgbm90IHNldCwgd2Ugd2lsbCBuZWVkIDErMSs1MTIgcGFnZXMgKGFr
YSAyTSArIDhrKQorCSAqIHRvIG1hcCAxRyByYW5nZSB3aXRoIFBURS4gVXNlIDUgYXMgc2hpZnQg
Zm9yIG5vdy4KKwkgKi8KKwl1bnNpZ25lZCBsb25nIG5ld19zdGVwX3NpemUgPSBzdGVwX3NpemUg
PDwgNTsKKworCWlmIChuZXdfc3RlcF9zaXplID4gc3RlcF9zaXplKQorCQlzdGVwX3NpemUgPSBu
ZXdfc3RlcF9zaXplOworCisJcmV0dXJuICBzdGVwX3NpemU7Cit9CisKIHZvaWQgX19pbml0IGlu
aXRfbWVtX21hcHBpbmcodm9pZCkKIHsKIAl1bnNpZ25lZCBsb25nIGVuZCwgcmVhbF9lbmQsIHN0
YXJ0LCBsYXN0X3N0YXJ0OwpAQCAtNDMyLDcgKzQ0Nyw3IEBAIHZvaWQgX19pbml0IGluaXRfbWVt
X21hcHBpbmcodm9pZCkKIAkJbWluX3Bmbl9tYXBwZWQgPSBsYXN0X3N0YXJ0ID4+IFBBR0VfU0hJ
RlQ7CiAJCS8qIG9ubHkgaW5jcmVhc2Ugc3RlcF9zaXplIGFmdGVyIGJpZyByYW5nZSBnZXQgbWFw
cGVkICovCiAJCWlmIChuZXdfbWFwcGVkX3JhbV9zaXplID4gbWFwcGVkX3JhbV9zaXplKQotCQkJ
c3RlcF9zaXplIDw8PSBTVEVQX1NJWkVfU0hJRlQ7CisJCQlzdGVwX3NpemUgPSBnZXRfbmV3X3N0
ZXBfc2l6ZShzdGVwX3NpemUpOwogCQltYXBwZWRfcmFtX3NpemUgKz0gbmV3X21hcHBlZF9yYW1f
c2l6ZTsKIAl9CiAK
--14dae93410eb0ba37104d8398df5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

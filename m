Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7911E6B0253
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 14:24:17 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id c20so186496187itb.5
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:24:17 -0800 (PST)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id w189si21011665itd.69.2016.12.27.11.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 11:24:17 -0800 (PST)
Received: by mail-it0-x241.google.com with SMTP id b123so34434319itb.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:24:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzKuiLS0CvTTqo5=8eyoksC1==30+XMiXZhQqzXr9JM3A@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <CA+55aFzKuiLS0CvTTqo5=8eyoksC1==30+XMiXZhQqzXr9JM3A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Dec 2016 11:24:16 -0800
Message-ID: <CA+55aFzNU53+9PT_xzrPRYdbUYP6V4Y52wCo8V_tANB0tLStnw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: multipart/mixed; boundary=94eb2c19d67654b37b0544a8cc8b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

--94eb2c19d67654b37b0544a8cc8b
Content-Type: text/plain; charset=UTF-8

On Tue, Dec 27, 2016 at 11:23 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Of course, none of this is *tested*, but it looks superficially
> correct, and allows other architectures to do the same optimization if
> they want.

Oops. I should include the actual patch I was talking about too, shouldn't I?

              Linus

--94eb2c19d67654b37b0544a8cc8b
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ix7wil490

IGFyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oIHwgMTMgKysrKysrKysrKysrKwogaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmggICAgfCAgMiArLQogbW0vZmlsZW1hcC5jICAgICAgICAgICAg
ICAgICAgfCAyNCArKysrKysrKysrKysrKysrKysrKystLS0KIDMgZmlsZXMgY2hhbmdlZCwgMzUg
aW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9pbmNs
dWRlL2FzbS9iaXRvcHMuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oCmluZGV4IDY4
NTU3ZjUyYjk2MS4uMzRlYWU0ODRhMTczIDEwMDY0NAotLS0gYS9hcmNoL3g4Ni9pbmNsdWRlL2Fz
bS9iaXRvcHMuaAorKysgYi9hcmNoL3g4Ni9pbmNsdWRlL2FzbS9iaXRvcHMuaApAQCAtMTM5LDYg
KzEzOSwxOSBAQCBzdGF0aWMgX19hbHdheXNfaW5saW5lIHZvaWQgX19jbGVhcl9iaXQobG9uZyBu
ciwgdm9sYXRpbGUgdW5zaWduZWQgbG9uZyAqYWRkcikKIAlhc20gdm9sYXRpbGUoImJ0ciAlMSwl
MCIgOiBBRERSIDogIklyIiAobnIpKTsKIH0KIAorc3RhdGljIF9fYWx3YXlzX2lubGluZSBib29s
IGNsZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZShsb25nIG5yLCB2b2xhdGlsZSB1bnNp
Z25lZCBsb25nICphZGRyKQoreworCWJvb2wgbmVnYXRpdmU7CisJYXNtIHZvbGF0aWxlKExPQ0tf
UFJFRklYICJhbmRiICUyLCUxXG5cdCIKKwkJQ0NfU0VUKHMpCisJCTogQ0NfT1VUKHMpIChuZWdh
dGl2ZSksIEFERFIKKwkJOiAiSXIiICgxIDw8IG5yKSA6ICJtZW1vcnkiKTsKKwlyZXR1cm4gbmVn
YXRpdmU7Cit9CisKKy8vIExldCBldmVyeWJvZHkga25vdyB3ZSBoYXZlIGl0CisjZGVmaW5lIGNs
ZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZSBjbGVhcl9iaXRfdW5sb2NrX2lzX25lZ2F0
aXZlX2J5dGUKKwogLyoKICAqIF9fY2xlYXJfYml0X3VubG9jayAtIENsZWFycyBhIGJpdCBpbiBt
ZW1vcnkKICAqIEBucjogQml0IHRvIGNsZWFyCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L3Bh
Z2UtZmxhZ3MuaCBiL2luY2x1ZGUvbGludXgvcGFnZS1mbGFncy5oCmluZGV4IGM1NmIzOTg5MGE0
MS4uNmI1ODE4ZDZkZTMyIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L3BhZ2UtZmxhZ3MuaAor
KysgYi9pbmNsdWRlL2xpbnV4L3BhZ2UtZmxhZ3MuaApAQCAtNzMsMTMgKzczLDEzIEBACiAgKi8K
IGVudW0gcGFnZWZsYWdzIHsKIAlQR19sb2NrZWQsCQkvKiBQYWdlIGlzIGxvY2tlZC4gRG9uJ3Qg
dG91Y2guICovCi0JUEdfd2FpdGVycywJCS8qIFBhZ2UgaGFzIHdhaXRlcnMsIGNoZWNrIGl0cyB3
YWl0cXVldWUgKi8KIAlQR19lcnJvciwKIAlQR19yZWZlcmVuY2VkLAogCVBHX3VwdG9kYXRlLAog
CVBHX2RpcnR5LAogCVBHX2xydSwKIAlQR19hY3RpdmUsCisJUEdfd2FpdGVycywJCS8qIFBhZ2Ug
aGFzIHdhaXRlcnMsIGNoZWNrIGl0cyB3YWl0cXVldWUuIE11c3QgYmUgYml0ICM3IGFuZCBpbiB0
aGUgc2FtZSBieXRlIGFzICJQR19sb2NrZWQiICovCiAJUEdfc2xhYiwKIAlQR19vd25lcl9wcml2
XzEsCS8qIE93bmVyIHVzZS4gSWYgcGFnZWNhY2hlLCBmcyBtYXkgdXNlKi8KIAlQR19hcmNoXzEs
CmRpZmYgLS1naXQgYS9tbS9maWxlbWFwLmMgYi9tbS9maWxlbWFwLmMKaW5kZXggODJmMjZjZGU4
MzBjLi4wMWEyZDRhNjU3MWMgMTAwNjQ0Ci0tLSBhL21tL2ZpbGVtYXAuYworKysgYi9tbS9maWxl
bWFwLmMKQEAgLTkxMiw2ICs5MTIsMjUgQEAgdm9pZCBhZGRfcGFnZV93YWl0X3F1ZXVlKHN0cnVj
dCBwYWdlICpwYWdlLCB3YWl0X3F1ZXVlX3QgKndhaXRlcikKIH0KIEVYUE9SVF9TWU1CT0xfR1BM
KGFkZF9wYWdlX3dhaXRfcXVldWUpOwogCisjaWZuZGVmIGNsZWFyX2JpdF91bmxvY2tfaXNfbmVn
YXRpdmVfYnl0ZQorCisvKgorICogUEdfd2FpdGVycyBpcyB0aGUgaGlnaCBiaXQgaW4gdGhlIHNh
bWUgYnl0ZSBhcyBQR19sb2NrLgorICoKKyAqIE9uIHg4NiAoYW5kIG9uIG1hbnkgb3RoZXIgYXJj
aGl0ZWN0dXJlcyksIHdlIGNhbiBjbGVhciBQR19sb2NrIGFuZAorICogdGVzdCB0aGUgc2lnbiBi
aXQgYXQgdGhlIHNhbWUgdGltZS4gQnV0IGlmIHRoZSBhcmNoaXRlY3R1cmUgZG9lcworICogbm90
IHN1cHBvcnQgdGhhdCBzcGVjaWFsIG9wZXJhdGlvbiwgd2UganVzdCBkbyB0aGlzIGFsbCBieSBo
YW5kCisgKiBpbnN0ZWFkLgorICovCitzdGF0aWMgaW5saW5lIGJvb2wgY2xlYXJfYml0X3VubG9j
a19pc19uZWdhdGl2ZV9ieXRlKGxvbmcgbnIsIHZvbGF0aWxlIHZvaWQgKm1lbSkKK3sKKwljbGVh
cl9iaXRfdW5sb2NrKFBHX2xvY2tlZCwgbWVtKTsKKwlzbXBfbWJfX2FmdGVyX2F0b21pYygpOwor
CXJldHVybiB0ZXN0X2JpdChQR193YWl0ZXJzKTsKK30KKworI2VuZGlmCisKIC8qKgogICogdW5s
b2NrX3BhZ2UgLSB1bmxvY2sgYSBsb2NrZWQgcGFnZQogICogQHBhZ2U6IHRoZSBwYWdlCkBAIC05
MjgsOSArOTQ3LDggQEAgdm9pZCB1bmxvY2tfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSkKIHsKIAlw
YWdlID0gY29tcG91bmRfaGVhZChwYWdlKTsKIAlWTV9CVUdfT05fUEFHRSghUGFnZUxvY2tlZChw
YWdlKSwgcGFnZSk7Ci0JY2xlYXJfYml0X3VubG9jayhQR19sb2NrZWQsICZwYWdlLT5mbGFncyk7
Ci0Jc21wX21iX19hZnRlcl9hdG9taWMoKTsKLQl3YWtlX3VwX3BhZ2UocGFnZSwgUEdfbG9ja2Vk
KTsKKwlpZiAoY2xlYXJfYml0X3VubG9ja19pc19uZWdhdGl2ZV9ieXRlKFBHX2xvY2tlZCwgJnBh
Z2UtPmZsYWdzKSkKKwkJd2FrZV91cF9wYWdlX2JpdChwYWdlLCBQR19sb2NrZWQpOwogfQogRVhQ
T1JUX1NZTUJPTCh1bmxvY2tfcGFnZSk7CiAK
--94eb2c19d67654b37b0544a8cc8b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

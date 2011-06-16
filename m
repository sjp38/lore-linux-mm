Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 357B66B00EE
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:07:08 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5GL6Zuw010375
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:06:36 -0700
Received: by wwi36 with SMTP id 36so1662384wwi.26
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:06:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 14:06:15 -0700
Message-ID: <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: multipart/mixed; boundary=0016e6dd9771ea1e3b04a5daa443
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

--0016e6dd9771ea1e3b04a5daa443
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jun 16, 2011 at 2:05 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> This patch is UNTESTED!

It was also UNATTACHED!

Now it's attached.

                    Linus

--0016e6dd9771ea1e3b04a5daa443
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gp0790mx0

IG1tL3JtYXAuYyB8ICAgNTEgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKystLS0t
LS0tLS0tLS0tLS0tCiAxIGZpbGVzIGNoYW5nZWQsIDM1IGluc2VydGlvbnMoKyksIDE2IGRlbGV0
aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL3JtYXAuYyBiL21tL3JtYXAuYwppbmRleCAwZWI0NjNl
YTg4ZGQuLmQxZDI2OTAwYzA4MiAxMDA2NDQKLS0tIGEvbW0vcm1hcC5jCisrKyBiL21tL3JtYXAu
YwpAQCAtMjA4LDEzICsyMDgsMTEgQEAgc3RhdGljIHZvaWQgYW5vbl92bWFfY2hhaW5fbGluayhz
dHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwKIAlhdmMtPmFub25fdm1hID0gYW5vbl92bWE7CiAJ
bGlzdF9hZGQoJmF2Yy0+c2FtZV92bWEsICZ2bWEtPmFub25fdm1hX2NoYWluKTsKIAotCWFub25f
dm1hX2xvY2soYW5vbl92bWEpOwogCS8qCiAJICogSXQncyBjcml0aWNhbCB0byBhZGQgbmV3IHZt
YXMgdG8gdGhlIHRhaWwgb2YgdGhlIGFub25fdm1hLAogCSAqIHNlZSBjb21tZW50IGluIGh1Z2Vf
bWVtb3J5LmM6X19zcGxpdF9odWdlX3BhZ2UoKS4KIAkgKi8KIAlsaXN0X2FkZF90YWlsKCZhdmMt
PnNhbWVfYW5vbl92bWEsICZhbm9uX3ZtYS0+aGVhZCk7Ci0JYW5vbl92bWFfdW5sb2NrKGFub25f
dm1hKTsKIH0KIAogLyoKQEAgLTIyNCwxNiArMjIyLDMwIEBAIHN0YXRpYyB2b2lkIGFub25fdm1h
X2NoYWluX2xpbmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiBpbnQgYW5vbl92bWFfY2xv
bmUoc3RydWN0IHZtX2FyZWFfc3RydWN0ICpkc3QsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqc3Jj
KQogewogCXN0cnVjdCBhbm9uX3ZtYV9jaGFpbiAqYXZjLCAqcGF2YzsKKwlzdHJ1Y3QgYW5vbl92
bWEgKnJvb3QgPSBOVUxMOwogCiAJbGlzdF9mb3JfZWFjaF9lbnRyeV9yZXZlcnNlKHBhdmMsICZz
cmMtPmFub25fdm1hX2NoYWluLCBzYW1lX3ZtYSkgeworCQlzdHJ1Y3QgYW5vbl92bWEgKmFub25f
dm1hID0gcGF2Yy0+YW5vbl92bWEsICpuZXdfcm9vdCA9IGFub25fdm1hLT5yb290OworCisJCWlm
IChuZXdfcm9vdCAhPSByb290KSB7CisJCQlpZiAoV0FSTl9PTl9PTkNFKHJvb3QpKQorCQkJCW11
dGV4X3VubG9jaygmcm9vdC0+bXV0ZXgpOworCQkJcm9vdCA9IG5ld19yb290OworCQkJbXV0ZXhf
bG9jaygmcm9vdC0+bXV0ZXgpOworCQl9CisKIAkJYXZjID0gYW5vbl92bWFfY2hhaW5fYWxsb2Mo
KTsKIAkJaWYgKCFhdmMpCiAJCQlnb3RvIGVub21lbV9mYWlsdXJlOwogCQlhbm9uX3ZtYV9jaGFp
bl9saW5rKGRzdCwgYXZjLCBwYXZjLT5hbm9uX3ZtYSk7CiAJfQorCWlmIChyb290KQorCQltdXRl
eF91bmxvY2soJnJvb3QtPm11dGV4KTsKIAlyZXR1cm4gMDsKIAogIGVub21lbV9mYWlsdXJlOgor
CWlmIChyb290KQorCQltdXRleF91bmxvY2soJnJvb3QtPm11dGV4KTsKIAl1bmxpbmtfYW5vbl92
bWFzKGRzdCk7CiAJcmV0dXJuIC1FTk9NRU07CiB9CkBAIC0yODAsNyArMjkyLDkgQEAgaW50IGFu
b25fdm1hX2Zvcmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0
cnVjdCAqcHZtYSkKIAlnZXRfYW5vbl92bWEoYW5vbl92bWEtPnJvb3QpOwogCS8qIE1hcmsgdGhp
cyBhbm9uX3ZtYSBhcyB0aGUgb25lIHdoZXJlIG91ciBuZXcgKENPV2VkKSBwYWdlcyBnby4gKi8K
IAl2bWEtPmFub25fdm1hID0gYW5vbl92bWE7CisJYW5vbl92bWFfbG9jayhhbm9uX3ZtYSk7CiAJ
YW5vbl92bWFfY2hhaW5fbGluayh2bWEsIGF2YywgYW5vbl92bWEpOworCWFub25fdm1hX3VubG9j
ayhhbm9uX3ZtYSk7CiAKIAlyZXR1cm4gMDsKIApAQCAtMjkxLDM5ICszMDUsNDQgQEAgaW50IGFu
b25fdm1hX2Zvcmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0
cnVjdCAqcHZtYSkKIAlyZXR1cm4gLUVOT01FTTsKIH0KIAotc3RhdGljIHZvaWQgYW5vbl92bWFf
dW5saW5rKHN0cnVjdCBhbm9uX3ZtYV9jaGFpbiAqYW5vbl92bWFfY2hhaW4pCitzdGF0aWMgdm9p
ZCBhbm9uX3ZtYV91bmxpbmsoc3RydWN0IGFub25fdm1hX2NoYWluICphbm9uX3ZtYV9jaGFpbiwg
c3RydWN0IGFub25fdm1hICphbm9uX3ZtYSkKIHsKLQlzdHJ1Y3QgYW5vbl92bWEgKmFub25fdm1h
ID0gYW5vbl92bWFfY2hhaW4tPmFub25fdm1hOwotCWludCBlbXB0eTsKLQotCS8qIElmIGFub25f
dm1hX2ZvcmsgZmFpbHMsIHdlIGNhbiBnZXQgYW4gZW1wdHkgYW5vbl92bWFfY2hhaW4uICovCi0J
aWYgKCFhbm9uX3ZtYSkKLQkJcmV0dXJuOwotCi0JYW5vbl92bWFfbG9jayhhbm9uX3ZtYSk7CiAJ
bGlzdF9kZWwoJmFub25fdm1hX2NoYWluLT5zYW1lX2Fub25fdm1hKTsKIAogCS8qIFdlIG11c3Qg
Z2FyYmFnZSBjb2xsZWN0IHRoZSBhbm9uX3ZtYSBpZiBpdCdzIGVtcHR5ICovCi0JZW1wdHkgPSBs
aXN0X2VtcHR5KCZhbm9uX3ZtYS0+aGVhZCk7Ci0JYW5vbl92bWFfdW5sb2NrKGFub25fdm1hKTsK
LQotCWlmIChlbXB0eSkKKwlpZiAobGlzdF9lbXB0eSgmYW5vbl92bWEtPmhlYWQpKQogCQlwdXRf
YW5vbl92bWEoYW5vbl92bWEpOwogfQogCiB2b2lkIHVubGlua19hbm9uX3ZtYXMoc3RydWN0IHZt
X2FyZWFfc3RydWN0ICp2bWEpCiB7CiAJc3RydWN0IGFub25fdm1hX2NoYWluICphdmMsICpuZXh0
OworCXN0cnVjdCBhbm9uX3ZtYSAqcm9vdCA9IE5VTEw7CiAKIAkvKgogCSAqIFVubGluayBlYWNo
IGFub25fdm1hIGNoYWluZWQgdG8gdGhlIFZNQS4gIFRoaXMgbGlzdCBpcyBvcmRlcmVkCiAJICog
ZnJvbSBuZXdlc3QgdG8gb2xkZXN0LCBlbnN1cmluZyB0aGUgcm9vdCBhbm9uX3ZtYSBnZXRzIGZy
ZWVkIGxhc3QuCiAJICovCiAJbGlzdF9mb3JfZWFjaF9lbnRyeV9zYWZlKGF2YywgbmV4dCwgJnZt
YS0+YW5vbl92bWFfY2hhaW4sIHNhbWVfdm1hKSB7Ci0JCWFub25fdm1hX3VubGluayhhdmMpOwor
CQlzdHJ1Y3QgYW5vbl92bWEgKmFub25fdm1hID0gYXZjLT5hbm9uX3ZtYTsKKworCQkvKiBJZiBh
bm9uX3ZtYV9mb3JrIGZhaWxzLCB3ZSBjYW4gZ2V0IGFuIGVtcHR5IGFub25fdm1hX2NoYWluLiAq
LworCQlpZiAoYW5vbl92bWEpIHsKKwkJCXN0cnVjdCBhbm9uX3ZtYSAqbmV3X3Jvb3QgPSBhbm9u
X3ZtYS0+cm9vdDsKKworCQkJaWYgKG5ld19yb290ICE9IHJvb3QpIHsKKwkJCQlpZiAoV0FSTl9P
Tl9PTkNFKHJvb3QpKQorCQkJCQltdXRleF91bmxvY2soJnJvb3QtPm11dGV4KTsKKwkJCQlyb290
ID0gbmV3X3Jvb3Q7CisJCQkJbXV0ZXhfbG9jaygmcm9vdC0+bXV0ZXgpOworCQkJfQorCQkJYW5v
bl92bWFfdW5saW5rKGF2YywgYW5vbl92bWEpOworCQl9CiAJCWxpc3RfZGVsKCZhdmMtPnNhbWVf
dm1hKTsKIAkJYW5vbl92bWFfY2hhaW5fZnJlZShhdmMpOwogCX0KKwlpZiAocm9vdCkKKwkJbXV0
ZXhfdW5sb2NrKCZyb290LT5tdXRleCk7CiB9CiAKIHN0YXRpYyB2b2lkIGFub25fdm1hX2N0b3Io
dm9pZCAqZGF0YSkK
--0016e6dd9771ea1e3b04a5daa443--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

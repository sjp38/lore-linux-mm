Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 414526B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:43:24 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so4723504vcb.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 13:43:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FF100F0.9050501@huawei.com>
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
	<CAE9FiQWzfLkeQs8O22MUEmuGUx=jPi5s=wZt2fcpFMcwrzt3uA@mail.gmail.com>
	<4FF100F0.9050501@huawei.com>
Date: Mon, 2 Jul 2012 13:43:22 -0700
Message-ID: <CAE9FiQXpeGFfWvUHHW_GjgTg+4Op7agsht5coZbcmn2W=f9bqw@mail.gmail.com>
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=20cf3071c79850171204c3ded926
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tony Luck <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

--20cf3071c79850171204c3ded926
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Sun, Jul 1, 2012 at 7:01 PM, Jiang Liu <jiang.liu@huawei.com> wrote:
> Hi Yinghai,
>         The patch fails compilation as below:
> mm/page_alloc.c:151: error: initializer element is not constant
> mm/page_alloc.c:151: error: expected =91,=92 or =91;=92 before =91__attri=
bute__=92
>
> On IA64, HUGETLB_PAGE_ORDER has dependency on variable hpage_shift.
> # define HUGETLB_PAGE_ORDER        (HPAGE_SHIFT - PAGE_SHIFT)
> # define HPAGE_SHIFT               hpage_shift
>
> And hpage_shift could be changed by early parameter "hugepagesz".
> So seems will still need to keep function set_pageblock_order().

ah,  then use use _DEFAULT instead and later could update that in earlypara=
m.

So attached -v2 should  work.

Thanks

Yinghai

--20cf3071c79850171204c3ded926
Content-Type: application/octet-stream;
	name="kill_set_pageblock_order_v2.patch"
Content-Disposition: attachment;
	filename="kill_set_pageblock_order_v2.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h460l7tl0

U3ViamVjdDogW1BBVENIXSBtbTogc2V0IHBhZ2VibG9ja19vcmRlciBpbiBjb21waWxpbmcgdGlt
ZQoKVGhhdCBpcyBpbml0aWFsIHNldHRpbmcsIGFuZCBjb3VsZCBiZSBvdmVycmlkZSBieSBjb21t
YW5kIGxpbmUuCgotdjI6IHVzZSBIUEFHRV9TSElGVF9ERUZBVUxUIGJ5IGRlZmF1bHQgYW5kIHNl
dCB0aGF0IGFnYWluIHdoZW4gaHBhZ2Vfc2hpZnQKICAgICBnZXQgdXBkYXRlZCBhZ2Fpbi4KClNp
Z25lZC1vZmYtYnk6IFlpbmdoYWkgTHUgPHlpbmdoYWlAa2VybmVsLm9yZz4KCi0tLQogYXJjaC9p
YTY0L21tL2h1Z2V0bGJwYWdlLmMgfCAgICA0ICsrKysKIG1tL3BhZ2VfYWxsb2MuYyAgICAgICAg
ICAgIHwgICA0NSArKysrKystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0K
IDIgZmlsZXMgY2hhbmdlZCwgMTAgaW5zZXJ0aW9ucygrKSwgMzkgZGVsZXRpb25zKC0pCgpJbmRl
eDogbGludXgtMi42L21tL3BhZ2VfYWxsb2MuYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3Jp
Zy9tbS9wYWdlX2FsbG9jLmMKKysrIGxpbnV4LTIuNi9tbS9wYWdlX2FsbG9jLmMKQEAgLTE0Nyw3
ICsxNDcsMTIgQEAgYm9vbCBwbV9zdXNwZW5kZWRfc3RvcmFnZSh2b2lkKQogI2VuZGlmIC8qIENP
TkZJR19QTV9TTEVFUCAqLwogCiAjaWZkZWYgQ09ORklHX0hVR0VUTEJfUEFHRV9TSVpFX1ZBUklB
QkxFCi1pbnQgcGFnZWJsb2NrX29yZGVyIF9fcmVhZF9tb3N0bHk7CisvKgorICogQXNzdW1lIHRo
ZSBsYXJnZXN0IGNvbnRpZ3VvdXMgb3JkZXIgb2YgaW50ZXJlc3QgaXMgYSBodWdlIHBhZ2UuCisg
KiBUaGlzIHZhbHVlIG1heSBiZSB2YXJpYWJsZSBkZXBlbmRpbmcgb24gYm9vdCBwYXJhbWV0ZXJz
IG9uIElBNjQgYW5kCisgKiBwb3dlcnBjLgorICovCitpbnQgcGFnZWJsb2NrX29yZGVyID0gKChI
UEFHRV9TSElGVF9ERUZBVUxUID4gUEFHRV9TSElGVCkgPyAoSFBBR0VfU0hJRlRfREVGQVVMVCAt
IFBBR0VfU0hJRlQpIDogKE1BWF9PUkRFUiAtIDEpKSBfX3JlYWRfbW9zdGx5OwogI2VuZGlmCiAK
IHN0YXRpYyB2b2lkIF9fZnJlZV9wYWdlc19vayhzdHJ1Y3QgcGFnZSAqcGFnZSwgdW5zaWduZWQg
aW50IG9yZGVyKTsKQEAgLTQyOTgsNDMgKzQzMDMsNiBAQCBzdGF0aWMgaW5saW5lIHZvaWQgc2V0
dXBfdXNlbWFwKHN0cnVjdCBwCiAJCQkJc3RydWN0IHpvbmUgKnpvbmUsIHVuc2lnbmVkIGxvbmcg
em9uZXNpemUpIHt9CiAjZW5kaWYgLyogQ09ORklHX1NQQVJTRU1FTSAqLwogCi0jaWZkZWYgQ09O
RklHX0hVR0VUTEJfUEFHRV9TSVpFX1ZBUklBQkxFCi0KLS8qIEluaXRpYWxpc2UgdGhlIG51bWJl
ciBvZiBwYWdlcyByZXByZXNlbnRlZCBieSBOUl9QQUdFQkxPQ0tfQklUUyAqLwotc3RhdGljIGlu
bGluZSB2b2lkIF9faW5pdCBzZXRfcGFnZWJsb2NrX29yZGVyKHZvaWQpCi17Ci0JdW5zaWduZWQg
aW50IG9yZGVyOwotCi0JLyogQ2hlY2sgdGhhdCBwYWdlYmxvY2tfbnJfcGFnZXMgaGFzIG5vdCBh
bHJlYWR5IGJlZW4gc2V0dXAgKi8KLQlpZiAocGFnZWJsb2NrX29yZGVyKQotCQlyZXR1cm47Ci0K
LQlpZiAoSFBBR0VfU0hJRlQgPiBQQUdFX1NISUZUKQotCQlvcmRlciA9IEhVR0VUTEJfUEFHRV9P
UkRFUjsKLQllbHNlCi0JCW9yZGVyID0gTUFYX09SREVSIC0gMTsKLQotCS8qCi0JICogQXNzdW1l
IHRoZSBsYXJnZXN0IGNvbnRpZ3VvdXMgb3JkZXIgb2YgaW50ZXJlc3QgaXMgYSBodWdlIHBhZ2Uu
Ci0JICogVGhpcyB2YWx1ZSBtYXkgYmUgdmFyaWFibGUgZGVwZW5kaW5nIG9uIGJvb3QgcGFyYW1l
dGVycyBvbiBJQTY0IGFuZAotCSAqIHBvd2VycGMuCi0JICovCi0JcGFnZWJsb2NrX29yZGVyID0g
b3JkZXI7Ci19Ci0jZWxzZSAvKiBDT05GSUdfSFVHRVRMQl9QQUdFX1NJWkVfVkFSSUFCTEUgKi8K
LQotLyoKLSAqIFdoZW4gQ09ORklHX0hVR0VUTEJfUEFHRV9TSVpFX1ZBUklBQkxFIGlzIG5vdCBz
ZXQsIHNldF9wYWdlYmxvY2tfb3JkZXIoKQotICogaXMgdW51c2VkIGFzIHBhZ2VibG9ja19vcmRl
ciBpcyBzZXQgYXQgY29tcGlsZS10aW1lLiBTZWUKLSAqIGluY2x1ZGUvbGludXgvcGFnZWJsb2Nr
LWZsYWdzLmggZm9yIHRoZSB2YWx1ZXMgb2YgcGFnZWJsb2NrX29yZGVyIGJhc2VkIG9uCi0gKiB0
aGUga2VybmVsIGNvbmZpZwotICovCi1zdGF0aWMgaW5saW5lIHZvaWQgc2V0X3BhZ2VibG9ja19v
cmRlcih2b2lkKQotewotfQotCi0jZW5kaWYgLyogQ09ORklHX0hVR0VUTEJfUEFHRV9TSVpFX1ZB
UklBQkxFICovCi0KIC8qCiAgKiBTZXQgdXAgdGhlIHpvbmUgZGF0YSBzdHJ1Y3R1cmVzOgogICog
ICAtIG1hcmsgYWxsIHBhZ2VzIHJlc2VydmVkCkBAIC00NDEzLDcgKzQzODEsNiBAQCBzdGF0aWMg
dm9pZCBfX3BhZ2luZ2luaXQgZnJlZV9hcmVhX2luaXRfCiAJCWlmICghc2l6ZSkKIAkJCWNvbnRp
bnVlOwogCi0JCXNldF9wYWdlYmxvY2tfb3JkZXIoKTsKIAkJc2V0dXBfdXNlbWFwKHBnZGF0LCB6
b25lLCBzaXplKTsKIAkJcmV0ID0gaW5pdF9jdXJyZW50bHlfZW1wdHlfem9uZSh6b25lLCB6b25l
X3N0YXJ0X3BmbiwKIAkJCQkJCXNpemUsIE1FTU1BUF9FQVJMWSk7CkluZGV4OiBsaW51eC0yLjYv
YXJjaC9pYTY0L21tL2h1Z2V0bGJwYWdlLmMKPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQotLS0gbGludXgtMi42Lm9yaWcv
YXJjaC9pYTY0L21tL2h1Z2V0bGJwYWdlLmMKKysrIGxpbnV4LTIuNi9hcmNoL2lhNjQvbW0vaHVn
ZXRsYnBhZ2UuYwpAQCAtMjAyLDYgKzIwMiwxMCBAQCBzdGF0aWMgaW50IF9faW5pdCBodWdldGxi
X3NldHVwX3N6KGNoYXIKIAkgKiBvdmVycmlkZSBoZXJlIHdpdGggbmV3IHBhZ2Ugc2hpZnQuCiAJ
ICovCiAJaWE2NF9zZXRfcnIoSFBBR0VfUkVHSU9OX0JBU0UsIGhwYWdlX3NoaWZ0IDw8IDIpOwor
CisJLyogdXBkYXRlIHBhZ2VibG9ja19vcmRlciBhY2NvcmRpbmdseSAqLworCXBhZ2VibG9ja19v
cmRlciA9ICgoSFBBR0VfU0hJRlQgPiBQQUdFX1NISUZUKSA/IEhVR0VUTEJfUEFHRV9PUkRFUiA6
IChNQVhfT1JERVIgLSAxKSkKKwogCXJldHVybiAwOwogfQogZWFybHlfcGFyYW0oImh1Z2VwYWdl
c3oiLCBodWdldGxiX3NldHVwX3N6KTsK
--20cf3071c79850171204c3ded926--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1F2156B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 13:29:06 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id ey16so6505440wid.5
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 10:29:04 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <51D45D1A.9060407@infradead.org>
References: <20130702223405.AF5BB5A4016@corp2gmr1-2.hot.corp.google.com>
	<51D45D1A.9060407@infradead.org>
Date: Wed, 3 Jul 2013 19:29:04 +0200
Message-ID: <CA+icZUUTiL_92tS1Xr+f=z5MfCbXqBDg-7Tm3Csn4gTiQyB18A@mail.gmail.com>
Subject: Re: mmotm 2013-07-02-15-32 uploaded (mm/memcontrol.c)
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: multipart/mixed; boundary=f46d043c7b405648d804e09eccb4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

--f46d043c7b405648d804e09eccb4
Content-Type: text/plain; charset=UTF-8

On Wed, Jul 3, 2013 at 7:19 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 07/02/13 15:34, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2013-07-02-15-32 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>
> on i386 and x86_64, in mmotm and linux-next of 20130703:
>
>
> mm/built-in.o: In function `mem_cgroup_css_free':
> memcontrol.c:(.text+0x39e67): undefined reference to `mem_cgroup_sockets_destroy'
>

Known issue in Linux-next.
See attached "unofficial" patch with references.

- Sedat -

>
> One failing randconfig file is attached.
>
> --
> ~Randy

--f46d043c7b405648d804e09eccb4
Content-Type: application/octet-stream;
	name="memcg-use-css_get-put-when-charging-uncharging-kmem-fix-2.patch"
Content-Disposition: attachment;
	filename="memcg-use-css_get-put-when-charging-uncharging-kmem-fix-2.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hiostrj51

RnJvbSBhOWFjOGFmYWVkZmY1ZjQ4MDUyYWZkZjUyY2ZlYTRmZDM1NDFkMjZlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBMaSBaZWZhbiA8bGl6ZWZhbkBodWF3ZWkuY29tPgpEYXRlOiBX
ZWQsIDMgSnVsIDIwMTMgMTU6MDA6MTMgKzAyMDAKU3ViamVjdDogW1BBVENIXSBtZW1jZzogZml4
IGJ1aWxkIGVycm9yIGlmIENPTkZJR19NRU1DR19LTUVNPW4KCkZpeCB0aGlzIGJ1aWxkIGVycm9y
OgoKbW0vYnVpbHQtaW4ubzogSW4gZnVuY3Rpb24gYG1lbV9jZ3JvdXBfY3NzX2ZyZWUnOgptZW1j
b250cm9sLmM6KC50ZXh0KzB4NWNhYTYpOiB1bmRlZmluZWQgcmVmZXJlbmNlIHRvICdtZW1fY2dy
b3VwX3NvY2tldHNfZGVzdHJveScKCk1heWJlIGl0J3MgYmV0dGVyIHRvIGFkZCBtZW1jZ19kZXN0
cm95X2ttZW0oKSwgdG8gcGFpciB3aXRoIG1lbWNnX2luaXRfa21lbSgpLgoKVGhpcyBwYXRjaCBj
YW4gYmUgZm9sZGVkIGludG8gIm1lbWNnOiB1c2UgY3NzX2dldC9wdXQgd2hlbiBjaGFyZ2luZy91
bmNoYXJnaW5nIGttZW0iLgoKUmVuYW1lIHRoZSBwYXRjaCBhcyBpdCBpcyBhIGZvbGxvdy11cCBm
b3IgdGhlIG1tb3RtIHRyZWU6CiJtZW1jZy11c2UtY3NzX2dldC1wdXQtd2hlbi1jaGFyZ2luZy11
bmNoYXJnaW5nLWttZW0tZml4LTIucGF0Y2giCgpTZWUgWzFdIGZvciB0aGUgb3JpZ2luYWwgcGF0
Y2ggYW5kIGZvbGxvdyB0aGUgZGlzY3Vzc2lvbiBpbiBbMl0uCgpbMV0gaHR0cDovL21hcmMuaW5m
by8/bD1saW51eC1tbSZtPTEzNzI4NTU5MDEyMzQzMCZ3PTIKWzJdIGh0dHA6Ly9tYXJjLmluZm8v
P3Q9MTM3Mjg1Mzc4NTAwMDA1JnI9MSZ3PTIKClJlcG9ydGVkLWJ5OiBGZW5nZ3VhbmcgV3UgPGZl
bmdndWFuZy53dUBpbnRlbC5jb20+ClJlcG9ydGVkLWJ5OiBTdGVwaGVuIFJvdGh3ZWxsIDxzZnJA
Y2FuYi5hdXVnLm9yZy5hdT4KUmVwb3J0ZWQtYnk6IFNlZGF0IERpbGVrIDxzZWRhdC5kaWxla0Bn
bWFpbC5jb20+ClRlc3RlZC1ieTogU2VkYXQgRGlsZWsgPHNlZGF0LmRpbGVrQGdtYWlsLmNvbT4K
QWNrZWQtYnk6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQHN1c2UuY3o+ClNpZ25lZC1vZmYtYnk6IExp
IFplZmFuIDxsaXplZmFuQGh1YXdlaS5jb20+Ci0tLQpbIGRpbGVrczoKICAqIEFkZCBjb21tZW50
cyBmcm9tIExpIFplZmFuCiAgKiBBZGQgc3VnZ2VzdGlvbiBmb3IgbmV3IHBhdGNoLW5hbWUgZnJv
bSBNaWNoYWwKICAqIEFkZCByZWZlcmVuY2VzIHRvIG9yaWctcGF0Y2ggYW5kIGRpc2N1c3Npb24g
XQoKIG1tL21lbWNvbnRyb2wuYyB8IDEyICsrKysrKysrKystLQogMSBmaWxlIGNoYW5nZWQsIDEw
IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbWVtY29udHJv
bC5jIGIvbW0vbWVtY29udHJvbC5jCmluZGV4IGQ2YTNlNTYuLjAwYTdhNjYgMTAwNjQ0Ci0tLSBh
L21tL21lbWNvbnRyb2wuYworKysgYi9tbS9tZW1jb250cm9sLmMKQEAgLTU4OTYsNiArNTg5Niwx
MSBAQCBzdGF0aWMgaW50IG1lbWNnX2luaXRfa21lbShzdHJ1Y3QgbWVtX2Nncm91cCAqbWVtY2cs
IHN0cnVjdCBjZ3JvdXBfc3Vic3lzICpzcykKIAlyZXR1cm4gbWVtX2Nncm91cF9zb2NrZXRzX2lu
aXQobWVtY2csIHNzKTsKIH0KIAorc3RhdGljIHZvaWQgbWVtY2dfZGVzdHJveV9rbWVtKHN0cnVj
dCBtZW1fY2dyb3VwICptZW1jZykKK3sKKwltZW1fY2dyb3VwX3NvY2tldHNfZGVzdHJveShtZW1j
Zyk7Cit9CisKIHN0YXRpYyB2b2lkIGttZW1fY2dyb3VwX2Nzc19vZmZsaW5lKHN0cnVjdCBtZW1f
Y2dyb3VwICptZW1jZykKIHsKIAlpZiAoIW1lbWNnX2ttZW1faXNfYWN0aXZlKG1lbWNnKSkKQEAg
LTU5MzUsNiArNTk0MCwxMCBAQCBzdGF0aWMgaW50IG1lbWNnX2luaXRfa21lbShzdHJ1Y3QgbWVt
X2Nncm91cCAqbWVtY2csIHN0cnVjdCBjZ3JvdXBfc3Vic3lzICpzcykKIAlyZXR1cm4gMDsKIH0K
IAorc3RhdGljIHZvaWQgbWVtY2dfZGVzdHJveV9rbWVtKHN0cnVjdCBtZW1fY2dyb3VwICptZW1j
ZykKK3sKK30KKwogc3RhdGljIHZvaWQga21lbV9jZ3JvdXBfY3NzX29mZmxpbmUoc3RydWN0IG1l
bV9jZ3JvdXAgKm1lbWNnKQogewogfQpAQCAtNjMzMiw4ICs2MzQxLDcgQEAgc3RhdGljIHZvaWQg
bWVtX2Nncm91cF9jc3NfZnJlZShzdHJ1Y3QgY2dyb3VwICpjb250KQogewogCXN0cnVjdCBtZW1f
Y2dyb3VwICptZW1jZyA9IG1lbV9jZ3JvdXBfZnJvbV9jb250KGNvbnQpOwogCi0JbWVtX2Nncm91
cF9zb2NrZXRzX2Rlc3Ryb3kobWVtY2cpOwotCisJbWVtY2dfZGVzdHJveV9rbWVtKG1lbWNnKTsK
IAlfX21lbV9jZ3JvdXBfZnJlZShtZW1jZyk7CiB9CiAKLS0gCjEuOC4zLjIKCg==
--f46d043c7b405648d804e09eccb4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

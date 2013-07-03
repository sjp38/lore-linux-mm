Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0D6DF6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 06:58:50 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id c10so6097719wiw.0
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 03:58:49 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUUWGa0f1pKM4Vegmk3Ns8cMbQcQTR6i=XGUtpr8CkvLYA@mail.gmail.com>
References: <CA+icZUUWGa0f1pKM4Vegmk3Ns8cMbQcQTR6i=XGUtpr8CkvLYA@mail.gmail.com>
Date: Wed, 3 Jul 2013 12:58:49 +0200
Message-ID: <CA+icZUWtvuq=KP2YsoUfWAZTzZWQymcXk72UbMquYGPCFkpnjg@mail.gmail.com>
Subject: Re: linux-next: Tree for Jul 3 [ BROKEN: memcontrol.c:(.text+0x5caa6):
 undefined reference to `mem_cgroup_sockets_destroy' ]
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: multipart/mixed; boundary=f46d044402d6b2005d04e0995800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>

--f46d044402d6b2005d04e0995800
Content-Type: text/plain; charset=UTF-8

On Wed, Jul 3, 2013 at 11:29 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Wed, Jul 3, 2013 at 10:06 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> Hi all,
>>
>> Changes since 20130702:
>>
>> The powerpc tree lost its build failure.
>>
>> The device-mapper tree gained a conflict against the md tree.
>>
>> The net-next tree gained a build failure for which I cherry-picked an
>> upcoming fix.
>>
>> The trivial tree gained conflicts against the btrfs and Linus' trees.
>>
>> The xen-two tree gained a conflict against the tip tree.
>>
>> The akpm tree lost some patches that turned up elsewhere.
>>
>> The cpuinit tree lost a patch that turned up elsewhere.
>>
>> ----------------------------------------------------------------------------
>>
>
> From my build-log:
> ...
>  CC      mm/memcontrol.o
> ...
>   MODPOST vmlinux.o
> WARNING: modpost: Found 1 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
>   GEN     .version
>   CHK     include/generated/compile.h
>   UPD     include/generated/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
> mm/built-in.o: In function `mem_cgroup_css_free':
> memcontrol.c:(.text+0x5caa6): undefined reference to
> `mem_cgroup_sockets_destroy'
> make[2]: *** [vmlinux] Error 1
> make[1]: *** [deb-pkg] Error 2
> make: *** [deb-pkg] Error 2
>
> My kernel-config is attached.
>

[ CC linux-mm and Li Zefan ]

Trying with the attached patch... Building...

- Sedat -


> - Sedat -

--f46d044402d6b2005d04e0995800
Content-Type: application/octet-stream;
	name="0001-memcg-Fix-build-failure-in-mem_cgroup_css_free.patch"
Content-Disposition: attachment;
	filename="0001-memcg-Fix-build-failure-in-mem_cgroup_css_free.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hioewc7l1

RnJvbSAzZTc4NTkyMDZjODI5OGI1ODc3OWE2ZTIwMDc0N2FlNDhhMDIxNDljIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBXZWQsIDMgSnVsIDIwMTMgMTI6NDU6NDAgKzAyMDAKU3ViamVjdDogW1BBVENIIG5leHQt
MjAxMzA3MDNdIG1lbWNnOiBGaXggYnVpbGQgZmFpbHVyZSBpbgogbWVtX2Nncm91cF9jc3NfZnJl
ZSgpCgpGcm9tIG15IGJ1aWxkLWxvZyBmb3IgbmV4dC0yMDEzMDcwMzoKLi4uCm1tL2J1aWx0LWlu
Lm86IEluIGZ1bmN0aW9uIGBtZW1fY2dyb3VwX2Nzc19mcmVlJzoKbWVtY29udHJvbC5jOigudGV4
dCsweDVjYWE2KTogdW5kZWZpbmVkIHJlZmVyZW5jZSB0byBgbWVtX2Nncm91cF9zb2NrZXRzX2Rl
c3Ryb3knCm1ha2VbMl06ICoqKiBbdm1saW51eF0gRXJyb3IKCmNvbW1pdCA0OWYyYjZiZWI0Mjgg
KCJtZW1jZzogdXNlIGNzc19nZXQvcHV0IHdoZW4gY2hhcmdpbmcvdW5jaGFyZ2luZyBrbWVtIikK
cmVuYW1lZCBrbWVtX2Nncm91cF9kZXN0cm95KCkgdG8ga21lbV9jZ3JvdXBfY3NzX29mZmxpbmUo
KS4KCi1zdGF0aWMgdm9pZCBrbWVtX2Nncm91cF9kZXN0cm95KHN0cnVjdCBtZW1fY2dyb3VwICpt
ZW1jZykKK3N0YXRpYyB2b2lkIGttZW1fY2dyb3VwX2Nzc19vZmZsaW5lKHN0cnVjdCBtZW1fY2dy
b3VwICptZW1jZykKCldoZXJlYXMgaW4gbWVtX2Nncm91cF9jc3NfZnJlZSgpIEkgc2VlIHRoaXM6
CgotIGttZW1fY2dyb3VwX2Rlc3Ryb3kobWVtY2cpOworIG1lbV9jZ3JvdXBfc29ja2V0c19kZXN0
cm95KG1lbWNnKTsKClRoaXMgc2hvdWxkIGJlIElNSE86CgorIGttZW1fY2dyb3VwX2Nzc19vZmZs
aW5lbWVtY2cpOwoKSSBhbSBub3Qgc3VyZSBpZiB0aGlzIHdhcyBpbnRlbmRlZCBhbmQgc3BlY3Vs
YXRlIHRoaXMgaXMgYSB0eXBvLgoKVGhpcyBwYXRjaCB0cmllcyB0byBmaXggdGhlIGlzc3VlLgoK
U2lnbmVkLW9mZi1ieTogU2VkYXQgRGlsZWsgPHNlZGF0LmRpbGVrQGdtYWlsLmNvbT4KLS0tCiBt
bS9tZW1jb250cm9sLmMgfCAyICstCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEg
ZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9tbS9tZW1jb250cm9sLmMgYi9tbS9tZW1jb250cm9s
LmMKaW5kZXggZDZhM2U1Ni4uY2E4ZDk4NSAxMDA2NDQKLS0tIGEvbW0vbWVtY29udHJvbC5jCisr
KyBiL21tL21lbWNvbnRyb2wuYwpAQCAtNjMzMiw3ICs2MzMyLDcgQEAgc3RhdGljIHZvaWQgbWVt
X2Nncm91cF9jc3NfZnJlZShzdHJ1Y3QgY2dyb3VwICpjb250KQogewogCXN0cnVjdCBtZW1fY2dy
b3VwICptZW1jZyA9IG1lbV9jZ3JvdXBfZnJvbV9jb250KGNvbnQpOwogCi0JbWVtX2Nncm91cF9z
b2NrZXRzX2Rlc3Ryb3kobWVtY2cpOworCW1lbV9jZ3JvdXBfY3NzX29mZmxpbmUobWVtY2cpOwog
CiAJX19tZW1fY2dyb3VwX2ZyZWUobWVtY2cpOwogfQotLSAKMS44LjMuMgoK
--f46d044402d6b2005d04e0995800--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

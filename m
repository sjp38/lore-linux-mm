Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8572A6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 23:31:57 -0400 (EDT)
Message-ID: <4E55C221.8080100@redhat.com>
Date: Thu, 25 Aug 2011 11:31:45 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] numa: introduce CONFIG_NUMA_SYSFS for drivers/base/node.c
References: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au>	<20110804152211.ea10e3e7.rdunlap@xenotime.net>	<20110823143912.0691d442.akpm@linux-foundation.org>	<4E547155.8090709@redhat.com> <20110824191430.8a908e70.rdunlap@xenotime.net>
In-Reply-To: <20110824191430.8a908e70.rdunlap@xenotime.net>
Content-Type: multipart/mixed;
 boundary="------------020109010904020706070702"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, gregkh@suse.de, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------020109010904020706070702
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

ao? 2011a1'08ae??25ae?JPY 10:14, Randy Dunlap a??e??:
> On Wed, 24 Aug 2011 11:34:45 +0800 Cong Wang wrote:
>
>> Hi, Andrew,
>>
>> Do you think my patch below is better?
>
> Hi,
>
> This causes build errors for me because node.o is not being built:
>
> arch/x86/built-in.o: In function `topology_init':
> topology.c:(.init.text+0x3668): undefined reference to `register_one_node'
> drivers/built-in.o: In function `unregister_cpu':
> (.text+0x7aecc): undefined reference to `unregister_cpu_under_node'
> drivers/built-in.o: In function `register_cpu':
> (.cpuinit.text+0xc1): undefined reference to `register_cpu_under_node'

Ah, this is because I missed the part in include/linux/node.h. :)

Below is the updated version.

Thanks for testing!

--------------020109010904020706070702
Content-Type: text/plain;
 name="n.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="n.diff"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvYmFzZS9NYWtlZmlsZSBiL2RyaXZlcnMvYmFzZS9NYWtl
ZmlsZQppbmRleCA5OWEzNzVhLi5lMzgyMzM4IDEwMDY0NAotLS0gYS9kcml2ZXJzL2Jhc2Uv
TWFrZWZpbGUKKysrIGIvZHJpdmVycy9iYXNlL01ha2VmaWxlCkBAIC0xMCw3ICsxMCw3IEBA
IG9iai0kKENPTkZJR19IQVNfRE1BKQkrPSBkbWEtbWFwcGluZy5vCiBvYmotJChDT05GSUdf
SEFWRV9HRU5FUklDX0RNQV9DT0hFUkVOVCkgKz0gZG1hLWNvaGVyZW50Lm8KIG9iai0kKENP
TkZJR19JU0EpCSs9IGlzYS5vCiBvYmotJChDT05GSUdfRldfTE9BREVSKQkrPSBmaXJtd2Fy
ZV9jbGFzcy5vCi1vYmotJChDT05GSUdfTlVNQSkJKz0gbm9kZS5vCitvYmotJChDT05GSUdf
TlVNQV9TWVNGUykJKz0gbm9kZS5vCiBvYmotJChDT05GSUdfTUVNT1JZX0hPVFBMVUdfU1BB
UlNFKSArPSBtZW1vcnkubwogb2JqLSQoQ09ORklHX1NNUCkJKz0gdG9wb2xvZ3kubwogaWZl
cSAoJChDT05GSUdfU1lTRlMpLHkpCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L25vZGUu
aCBiL2luY2x1ZGUvbGludXgvbm9kZS5oCmluZGV4IDkyMzcwZTIuLmEwY2M1ZjkgMTAwNjQ0
Ci0tLSBhL2luY2x1ZGUvbGludXgvbm9kZS5oCisrKyBiL2luY2x1ZGUvbGludXgvbm9kZS5o
CkBAIC0zMiw3ICszMiw3IEBAIHR5cGVkZWYgIHZvaWQgKCpub2RlX3JlZ2lzdHJhdGlvbl9m
dW5jX3QpKHN0cnVjdCBub2RlICopOwogCiBleHRlcm4gaW50IHJlZ2lzdGVyX25vZGUoc3Ry
dWN0IG5vZGUgKiwgaW50LCBzdHJ1Y3Qgbm9kZSAqKTsKIGV4dGVybiB2b2lkIHVucmVnaXN0
ZXJfbm9kZShzdHJ1Y3Qgbm9kZSAqbm9kZSk7Ci0jaWZkZWYgQ09ORklHX05VTUEKKyNpZmRl
ZiBkZWZpbmVkKENPTkZJR19OVU1BKSAmJiBkZWZpbmVkKENPTkZJR19TWVNGUykKIGV4dGVy
biBpbnQgcmVnaXN0ZXJfb25lX25vZGUoaW50IG5pZCk7CiBleHRlcm4gdm9pZCB1bnJlZ2lz
dGVyX29uZV9ub2RlKGludCBuaWQpOwogZXh0ZXJuIGludCByZWdpc3Rlcl9jcHVfdW5kZXJf
bm9kZSh1bnNpZ25lZCBpbnQgY3B1LCB1bnNpZ25lZCBpbnQgbmlkKTsKZGlmZiAtLWdpdCBh
L21tL0tjb25maWcgYi9tbS9LY29uZmlnCmluZGV4IGYyZjFjYTEuLjc3MzQ1ZTcgMTAwNjQ0
Ci0tLSBhL21tL0tjb25maWcKKysrIGIvbW0vS2NvbmZpZwpAQCAtMzQwLDYgKzM0MCwxNiBA
QCBjaG9pY2UKIAkgIGJlbmVmaXQuCiBlbmRjaG9pY2UKIAorY29uZmlnIE5VTUFfU1lTRlMK
Kwlib29sICJFbmFibGUgTlVNQSBzeXNmcyBpbnRlcmZhY2UgZm9yIHVzZXItc3BhY2UiCisJ
ZGVwZW5kcyBvbiBOVU1BCisJZGVwZW5kcyBvbiBTWVNGUworCWRlZmF1bHQgeQorCWhlbHAK
KwkgIFRoaXMgZW5hYmxlcyBOVU1BIHN5c2ZzIGludGVyZmFjZSwgL3N5cy9kZXZpY2VzL3N5
c3RlbS9ub2RlLyoKKwkgIGZpbGVzLCBmb3IgdXNlci1zcGFjZSB0b29scywgbGlrZSBudW1h
Y3RsLiBJZiB5b3UgaGF2ZSBlbmFibGVkCisJICBOVU1BLCBwcm9iYWJseSB5b3UgYWxzbyBu
ZWVkIHRoaXMgb25lLgorCiAjCiAjIFVQIGFuZCBub21tdSBhcmNocyB1c2Uga20gYmFzZWQg
cGVyY3B1IGFsbG9jYXRvcgogIwo=
--------------020109010904020706070702--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

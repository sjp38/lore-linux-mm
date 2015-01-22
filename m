Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D9A6B6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 00:53:07 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so23536473pac.13
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 21:53:07 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ce14si6259932pdb.253.2015.01.21.21.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 21:53:07 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so6300581pad.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 21:53:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGyXo=AMCU-2TbrrY=MPorg+Nd+WYS5nCAcjELZs91r4AQ@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
	<54C042D2.4040809@oracle.com>
	<CAPAsAGyXo=AMCU-2TbrrY=MPorg+Nd+WYS5nCAcjELZs91r4AQ@mail.gmail.com>
Date: Thu, 22 Jan 2015 09:53:06 +0400
Message-ID: <CAPAsAGyMyq_anQjErLa=L-0K3KmghMjoqzi0AdZOADTAECn1HA@mail.gmail.com>
Subject: Re: [PATCH v9 00/17] Kernel address sanitizer - runtime memory debugger.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: multipart/mixed; boundary=001a11c3d66c3ec2ac050d374977
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

--001a11c3d66c3ec2ac050d374977
Content-Type: text/plain; charset=UTF-8

2015-01-22 8:34 GMT+03:00 Andrey Ryabinin <ryabinin.a.a@gmail.com>:
> 2015-01-22 3:22 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
>> On 01/21/2015 11:51 AM, Andrey Ryabinin wrote:
>>> Changes since v8:
>>>       - Fixed unpoisoned redzones for not-allocated-yet object
>>>           in newly allocated slab page. (from Dmitry C.)
>>>
>>>       - Some minor non-function cleanups in kasan internals.
>>>
>>>       - Added ack from Catalin
>>>
>>>       - Added stack instrumentation. With this we could detect
>>>           out of bounds accesses in stack variables. (patch 12)
>>>
>>>       - Added globals instrumentation - catching out of bounds in
>>>           global varibles. (patches 13-17)
>>>
>>>       - Shadow moved out from vmalloc into hole between vmemmap
>>>           and %esp fixup stacks. For globals instrumentation
>>>           we will need shadow backing modules addresses.
>>>           So we need some sort of a shadow memory allocator
>>>           (something like vmmemap_populate() function, except
>>>           that it should be available after boot).
>>>
>>>           __vmalloc_node_range() suits that purpose, except that
>>>           it can't be used for allocating for shadow in vmalloc
>>>           area because shadow in vmalloc is already 'allocated'
>>>           to protect us from other vmalloc users. So we need
>>>           16TB of unused addresses. And we have big enough hole
>>>           between vmemmap and %esp fixup stacks. So I moved shadow
>>>           there.
>>
>> I'm not sure which new addition caused it, but I'm getting tons of
>> false positives from platform drivers trying to access memory they
>> don't "own" - because they expect to find hardware there.
>>
>
> To be sure, that this is really false positives, could you try with
> patches in attachment?

Attaching properly formed patches

--001a11c3d66c3ec2ac050d374977
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-backlight-da9052_bl-terminate-da9052_wled_ids-array-.patch"
Content-Disposition: attachment;
	filename="0001-backlight-da9052_bl-terminate-da9052_wled_ids-array-.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57ylfp93

RnJvbSA4YWNhMjhkYzRkZjJlZDU5N2Y0ZmUwZDQ5NDY4MDIxZGI1ZjI5YzYxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZXkgUnlhYmluaW4gPGEucnlhYmluaW5Ac2Ftc3VuZy5j
b20+CkRhdGU6IFRodSwgMjIgSmFuIDIwMTUgMTI6NDQ6NDIgKzAzMDAKU3ViamVjdDogW1BBVENI
IDEvM10gYmFja2xpZ2h0OiBkYTkwNTJfYmw6IHRlcm1pbmF0ZSBkYTkwNTJfd2xlZF9pZHMgYXJy
YXkKIHdpdGggZW1wdHkgZWxlbWVudAoKQXJyYXkgb2YgcGxhdGZvcm1fZGV2aWNlX2lkIGVsZW1l
bnRzIHNob3VsZCBiZSB0ZXJtaW5hdGVkCndpdGggZW1wdHkgZWxlbWVudC4KClNpZ25lZC1vZmYt
Ynk6IEFuZHJleSBSeWFiaW5pbiA8YS5yeWFiaW5pbkBzYW1zdW5nLmNvbT4KLS0tCiBkcml2ZXJz
L3ZpZGVvL2JhY2tsaWdodC9kYTkwNTJfYmwuYyB8IDEgKwogMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy92aWRlby9iYWNrbGlnaHQvZGE5MDUyX2Js
LmMgYi9kcml2ZXJzL3ZpZGVvL2JhY2tsaWdodC9kYTkwNTJfYmwuYwppbmRleCBkNGJkNzRiZC4u
YjE5NDNlNyAxMDA2NDQKLS0tIGEvZHJpdmVycy92aWRlby9iYWNrbGlnaHQvZGE5MDUyX2JsLmMK
KysrIGIvZHJpdmVycy92aWRlby9iYWNrbGlnaHQvZGE5MDUyX2JsLmMKQEAgLTE2NSw2ICsxNjUs
NyBAQCBzdGF0aWMgc3RydWN0IHBsYXRmb3JtX2RldmljZV9pZCBkYTkwNTJfd2xlZF9pZHNbXSA9
IHsKIAkJLm5hbWUJCT0gImRhOTA1Mi13bGVkMyIsCiAJCS5kcml2ZXJfZGF0YQk9IERBOTA1Ml9U
WVBFX1dMRUQzLAogCX0sCisJeyB9LAogfTsKIAogc3RhdGljIHN0cnVjdCBwbGF0Zm9ybV9kcml2
ZXIgZGE5MDUyX3dsZWRfZHJpdmVyID0gewotLSAKMi4wLjQKCg==
--001a11c3d66c3ec2ac050d374977
Content-Type: text/x-patch; charset=US-ASCII;
	name="0002-crypto-ccp-terminate-ccp_support-array-with-empty-el.patch"
Content-Disposition: attachment;
	filename="0002-crypto-ccp-terminate-ccp_support-array-with-empty-el.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57ylfpq4

RnJvbSAyN2Y4Y2YwYWZmN2QxNmMwNjFkZGE5ZGQyMTk4ODdjYWUyMjE0NTg2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZXkgUnlhYmluaW4gPGEucnlhYmluaW5Ac2Ftc3VuZy5j
b20+CkRhdGU6IFRodSwgMjIgSmFuIDIwMTUgMTI6NDY6NDQgKzAzMDAKU3ViamVjdDogW1BBVENI
IDIvM10gY3J5cHRvOiBjY3A6IHRlcm1pbmF0ZSBjY3Bfc3VwcG9ydCBhcnJheSB3aXRoIGVtcHR5
CiBlbGVtZW50Cgp4ODZfbWF0Y2hfY3B1KCkgZXhwZWN0cyBhcnJheSBvZiB4ODZfY3B1X2lkcyB0
ZXJtaW5hdGVkCndpdGggZW1wdHkgZWxlbWVudC4KClNpZ25lZC1vZmYtYnk6IEFuZHJleSBSeWFi
aW5pbiA8YS5yeWFiaW5pbkBzYW1zdW5nLmNvbT4KLS0tCiBkcml2ZXJzL2NyeXB0by9jY3AvY2Nw
LWRldi5jIHwgMSArCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKykKCmRpZmYgLS1naXQg
YS9kcml2ZXJzL2NyeXB0by9jY3AvY2NwLWRldi5jIGIvZHJpdmVycy9jcnlwdG8vY2NwL2NjcC1k
ZXYuYwppbmRleCBjNmU2MTcxLi5jYTI5YzEyIDEwMDY0NAotLS0gYS9kcml2ZXJzL2NyeXB0by9j
Y3AvY2NwLWRldi5jCisrKyBiL2RyaXZlcnMvY3J5cHRvL2NjcC9jY3AtZGV2LmMKQEAgLTU4Myw2
ICs1ODMsNyBAQCBib29sIGNjcF9xdWV1ZXNfc3VzcGVuZGVkKHN0cnVjdCBjY3BfZGV2aWNlICpj
Y3ApCiAjaWZkZWYgQ09ORklHX1g4Ngogc3RhdGljIGNvbnN0IHN0cnVjdCB4ODZfY3B1X2lkIGNj
cF9zdXBwb3J0W10gPSB7CiAJeyBYODZfVkVORE9SX0FNRCwgMjIsIH0sCisJeyB9LAogfTsKICNl
bmRpZgogCi0tIAoyLjAuNAoK
--001a11c3d66c3ec2ac050d374977
Content-Type: text/x-patch; charset=US-ASCII;
	name="0003-rtc-s5m-terminate-s5m_rtc_id-array-with-empty-elemen.patch"
Content-Disposition: attachment;
	filename="0003-rtc-s5m-terminate-s5m_rtc_id-array-with-empty-elemen.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57ylfq05

RnJvbSAzYTNiZDljZmQyMjNmMTRkMzEzNTJiOWE0NDIwOTQ3NmIzZjVlZjExIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZXkgUnlhYmluaW4gPGEucnlhYmluaW5Ac2Ftc3VuZy5j
b20+CkRhdGU6IFRodSwgMjIgSmFuIDIwMTUgMTI6NDg6MTUgKzAzMDAKU3ViamVjdDogW1BBVENI
IDMvM10gcnRjOiBzNW06IHRlcm1pbmF0ZSBzNW1fcnRjX2lkIGFycmF5IHdpdGggZW1wdHkgZWxl
bWVudAoKQXJyYXkgb2YgcGxhdGZvcm1fZGV2aWNlX2lkIGVsZW1lbnRzIHNob3VsZCBiZSB0ZXJt
aW5hdGVkCndpdGggZW1wdHkgZWxlbWVudC4KClNpZ25lZC1vZmYtYnk6IEFuZHJleSBSeWFiaW5p
biA8YS5yeWFiaW5pbkBzYW1zdW5nLmNvbT4KLS0tCiBkcml2ZXJzL3J0Yy9ydGMtczVtLmMgfCAx
ICsKIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMv
cnRjL3J0Yy1zNW0uYyBiL2RyaXZlcnMvcnRjL3J0Yy1zNW0uYwppbmRleCBiNWU3YzQ2Li44OWFj
MWQ1IDEwMDY0NAotLS0gYS9kcml2ZXJzL3J0Yy9ydGMtczVtLmMKKysrIGIvZHJpdmVycy9ydGMv
cnRjLXM1bS5jCkBAIC04MzIsNiArODMyLDcgQEAgc3RhdGljIFNJTVBMRV9ERVZfUE1fT1BTKHM1
bV9ydGNfcG1fb3BzLCBzNW1fcnRjX3N1c3BlbmQsIHM1bV9ydGNfcmVzdW1lKTsKIHN0YXRpYyBj
b25zdCBzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlX2lkIHM1bV9ydGNfaWRbXSA9IHsKIAl7ICJzNW0t
cnRjIiwJCVM1TTg3NjdYIH0sCiAJeyAiczJtcHMxNC1ydGMiLAlTMk1QUzE0WCB9LAorCXsgfSwK
IH07CiAKIHN0YXRpYyBzdHJ1Y3QgcGxhdGZvcm1fZHJpdmVyIHM1bV9ydGNfZHJpdmVyID0gewot
LSAKMi4wLjQKCg==
--001a11c3d66c3ec2ac050d374977--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

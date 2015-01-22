Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 946EE6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 00:34:58 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so25125911pdb.5
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 21:34:58 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id cv4si11061453pbb.16.2015.01.21.21.34.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 21:34:57 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so13484781pab.12
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 21:34:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54C042D2.4040809@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
	<54C042D2.4040809@oracle.com>
Date: Thu, 22 Jan 2015 09:34:57 +0400
Message-ID: <CAPAsAGyXo=AMCU-2TbrrY=MPorg+Nd+WYS5nCAcjELZs91r4AQ@mail.gmail.com>
Subject: Re: [PATCH v9 00/17] Kernel address sanitizer - runtime memory debugger.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: multipart/mixed; boundary=001a1137e5f050554f050d370839
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

--001a1137e5f050554f050d370839
Content-Type: text/plain; charset=UTF-8

2015-01-22 3:22 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
> On 01/21/2015 11:51 AM, Andrey Ryabinin wrote:
>> Changes since v8:
>>       - Fixed unpoisoned redzones for not-allocated-yet object
>>           in newly allocated slab page. (from Dmitry C.)
>>
>>       - Some minor non-function cleanups in kasan internals.
>>
>>       - Added ack from Catalin
>>
>>       - Added stack instrumentation. With this we could detect
>>           out of bounds accesses in stack variables. (patch 12)
>>
>>       - Added globals instrumentation - catching out of bounds in
>>           global varibles. (patches 13-17)
>>
>>       - Shadow moved out from vmalloc into hole between vmemmap
>>           and %esp fixup stacks. For globals instrumentation
>>           we will need shadow backing modules addresses.
>>           So we need some sort of a shadow memory allocator
>>           (something like vmmemap_populate() function, except
>>           that it should be available after boot).
>>
>>           __vmalloc_node_range() suits that purpose, except that
>>           it can't be used for allocating for shadow in vmalloc
>>           area because shadow in vmalloc is already 'allocated'
>>           to protect us from other vmalloc users. So we need
>>           16TB of unused addresses. And we have big enough hole
>>           between vmemmap and %esp fixup stacks. So I moved shadow
>>           there.
>
> I'm not sure which new addition caused it, but I'm getting tons of
> false positives from platform drivers trying to access memory they
> don't "own" - because they expect to find hardware there.
>

To be sure, that this is really false positives, could you try with
patches in attachment?
That should fix some bugs in several platform drivers.

> I suspect we'd need to mark that memory region somehow to prevent
> accesses to it from triggering warnings?
>
>
> Thanks,
> Sasha
>

--001a1137e5f050554f050d370839
Content-Type: text/x-patch; charset=US-ASCII;
	name="backlight-da9052_bl-terminate-da9052_wled_ids-array-with-empty-element.patch"
Content-Disposition: attachment;
	filename="backlight-da9052_bl-terminate-da9052_wled_ids-array-with-empty-element.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57xbukf0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvdmlkZW8vYmFja2xpZ2h0L2RhOTA1Ml9ibC5jIGIvZHJpdmVy
cy92aWRlby9iYWNrbGlnaHQvZGE5MDUyX2JsLmMKaW5kZXggZDRiZDc0YmQuLmIxOTQzZTcgMTAw
NjQ0Ci0tLSBhL2RyaXZlcnMvdmlkZW8vYmFja2xpZ2h0L2RhOTA1Ml9ibC5jCisrKyBiL2RyaXZl
cnMvdmlkZW8vYmFja2xpZ2h0L2RhOTA1Ml9ibC5jCkBAIC0xNjUsNiArMTY1LDcgQEAgc3RhdGlj
IHN0cnVjdCBwbGF0Zm9ybV9kZXZpY2VfaWQgZGE5MDUyX3dsZWRfaWRzW10gPSB7CiAJCS5uYW1l
CQk9ICJkYTkwNTItd2xlZDMiLAogCQkuZHJpdmVyX2RhdGEJPSBEQTkwNTJfVFlQRV9XTEVEMywK
IAl9LAorCXsgfSwKIH07CiAKIHN0YXRpYyBzdHJ1Y3QgcGxhdGZvcm1fZHJpdmVyIGRhOTA1Ml93
bGVkX2RyaXZlciA9IHsK
--001a1137e5f050554f050d370839
Content-Type: text/x-patch; charset=US-ASCII;
	name="crypto-ccp-terminate-ccp_support-array-with-empty-element.patch"
Content-Disposition: attachment;
	filename="crypto-ccp-terminate-ccp_support-array-with-empty-element.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57xbum41

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvY3J5cHRvL2NjcC9jY3AtZGV2LmMgYi9kcml2ZXJzL2NyeXB0
by9jY3AvY2NwLWRldi5jCmluZGV4IGM2ZTYxNzEuLmNhMjljMTIgMTAwNjQ0Ci0tLSBhL2RyaXZl
cnMvY3J5cHRvL2NjcC9jY3AtZGV2LmMKKysrIGIvZHJpdmVycy9jcnlwdG8vY2NwL2NjcC1kZXYu
YwpAQCAtNTgzLDYgKzU4Myw3IEBAIGJvb2wgY2NwX3F1ZXVlc19zdXNwZW5kZWQoc3RydWN0IGNj
cF9kZXZpY2UgKmNjcCkKICNpZmRlZiBDT05GSUdfWDg2CiBzdGF0aWMgY29uc3Qgc3RydWN0IHg4
Nl9jcHVfaWQgY2NwX3N1cHBvcnRbXSA9IHsKIAl7IFg4Nl9WRU5ET1JfQU1ELCAyMiwgfSwKKwl7
IH0sCiB9OwogI2VuZGlmCiAK
--001a1137e5f050554f050d370839
Content-Type: text/x-patch; charset=US-ASCII;
	name="rtc-s5m-terminate-s5m_rtc_id-array-with-empty-element.patch"
Content-Disposition: attachment;
	filename="rtc-s5m-terminate-s5m_rtc_id-array-with-empty-element.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i57xbump2

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvcnRjL3J0Yy1zNW0uYyBiL2RyaXZlcnMvcnRjL3J0Yy1zNW0u
YwppbmRleCBiNWU3YzQ2Li44OWFjMWQ1IDEwMDY0NAotLS0gYS9kcml2ZXJzL3J0Yy9ydGMtczVt
LmMKKysrIGIvZHJpdmVycy9ydGMvcnRjLXM1bS5jCkBAIC04MzIsNiArODMyLDcgQEAgc3RhdGlj
IFNJTVBMRV9ERVZfUE1fT1BTKHM1bV9ydGNfcG1fb3BzLCBzNW1fcnRjX3N1c3BlbmQsIHM1bV9y
dGNfcmVzdW1lKTsKIHN0YXRpYyBjb25zdCBzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlX2lkIHM1bV9y
dGNfaWRbXSA9IHsKIAl7ICJzNW0tcnRjIiwJCVM1TTg3NjdYIH0sCiAJeyAiczJtcHMxNC1ydGMi
LAlTMk1QUzE0WCB9LAorCXsgfSwKIH07CiAKIHN0YXRpYyBzdHJ1Y3QgcGxhdGZvcm1fZHJpdmVy
IHM1bV9ydGNfZHJpdmVyID0gewo=
--001a1137e5f050554f050d370839--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

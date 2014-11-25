Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 32E666B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 08:09:18 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so559888pdb.4
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:09:17 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id qc5si1688928pac.236.2014.11.25.05.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 25 Nov 2014 05:09:16 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFL005R7JBWDF60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 25 Nov 2014 13:11:56 +0000 (GMT)
Message-id: <54747F74.8070808@samsung.com>
Date: Tue, 25 Nov 2014 16:09:08 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v7 11/12] lib: add kasan test module
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-12-git-send-email-a.ryabinin@samsung.com>
 <CAA6XgkEZD=+TvqXmO814nYi_oqp_3F7_NvkjEW0-X262xTiRDw@mail.gmail.com>
In-reply-to: 
 <CAA6XgkEZD=+TvqXmO814nYi_oqp_3F7_NvkjEW0-X262xTiRDw@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Chernenkov <dmitryc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/25/2014 02:14 PM, Dmitry Chernenkov wrote:
> I have a bit of concern about tests.
> A) they are not fully automated, there is no checking whether they
> pass or not. This is implemented in our repository using special tags
> in the log (https://github.com/google/kasan/commit/33b267553e7ffe66d5207152a3294112361b75fe;
> don't mmind the TODOs, they weren't broken to begin with), and a
> parser script (https://code.google.com/p/address-sanitizer/source/browse/trunk/tools/kernel_test_parse.py)
> to feed the kernel log to.
> 
> B) They are not thorough enough - they don't check false negatives,

False negative means kasan's report on valid access, right? Most of the memory accesses
in kernel are valid, so just booting kernel should give you the best check for false
negatives you can ever write.

Though I agree that it's not very thorough. Currently this more demonstrational module,
and there are a lot of cases not covered by it.

> accesses more than 1 byte away etc.
> 
> C) (more of general concern for current Kasan realiability) - when
> running multiple times, some tests are flaky, specificially oob_right
> and uaf2. The latter needs quarantine to work reliably (I know
> Konstantin is working on it). oob_right needs redzones in the
> beginning of the slabs.
> 
> I know all of these may seem like long shots, but if we want a
> reliable solution (also a backportable solution), we need to at least
> consider them.
> 
> Otherwise, LGTM
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

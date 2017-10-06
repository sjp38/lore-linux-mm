Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90A8C6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:11:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q203so13132739wmb.0
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:11:27 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.181])
        by mx.google.com with ESMTPS id f21si873520ede.332.2017.10.06.04.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:11:26 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v10 09/10] mm: stop zeroing memory during allocation in
 vmemmap
Date: Fri, 6 Oct 2017 11:10:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008BA85@AcuExch.aculab.com>
References: <20171005211124.26524-1-pasha.tatashin@oracle.com>
 <20171005211124.26524-10-pasha.tatashin@oracle.com>
In-Reply-To: <20171005211124.26524-10-pasha.tatashin@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Pavel Tatashin' <pasha.tatashin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "willy@infradead.org" <willy@infradead.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "sam@ravnborg.org" <sam@ravnborg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "bob.picco@oracle.com" <bob.picco@oracle.com>

From: Pavel Tatashin
> Sent: 05 October 2017 22:11
> vmemmap_alloc_block() will no longer zero the block, so zero memory
> at its call sites for everything except struct pages.  Struct page memory
> is zero'd by struct page initialization.

It seems dangerous to change an allocator to stop zeroing memory.
It is probably saver to add a new function that doesn't zero
the memory and use that is the places where you don't want it
to be zeroed.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

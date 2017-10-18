Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E445E6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:06:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b189so5232351oia.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:06:47 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j85si1434699oiy.438.2017.10.18.10.06.46
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 10:06:46 -0700 (PDT)
Date: Wed, 18 Oct 2017 18:06:51 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
Message-ID: <20171018170651.GG21820@arm.com>
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed, Oct 18, 2017 at 01:03:10PM -0400, Pavel Tatashin wrote:
> I asked Will, about it, and he preferred to have this patched added to the
> end of my series instead of replacing "arm64/kasan: add and use
> kasan_map_populate()".

As I said, I'm fine either way, I just didn't want to cause extra work
or rebasing:

http://lists.infradead.org/pipermail/linux-arm-kernel/2017-October/535703.html

> In addition, Will's patch stops using large pages for kasan memory, and thus
> might add some regression in which case it is easier to revert just that
> patch instead of the whole series. It is unlikely that regression is going
> to be detectable, because kasan by itself makes system quiet slow already.

If it causes problems, I'll just fix them. No need to revert.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

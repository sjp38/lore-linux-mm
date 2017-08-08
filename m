Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 305886B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:51:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k68so4410359wmd.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:51:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 4si1208367wrp.126.2017.08.08.05.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:51:48 -0700 (PDT)
Subject: Re: [v6 11/15] arm64/kasan: explicitly zero kasan shadow memory
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-12-git-send-email-pasha.tatashin@oracle.com>
 <20170808090743.GA12887@arm.com>
 <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
 <20170808123042.GG13355@arm.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a777718a-00b5-fb3a-75d6-03cc7ad181d9@oracle.com>
Date: Tue, 8 Aug 2017 08:49:55 -0400
MIME-Version: 1.0
In-Reply-To: <20170808123042.GG13355@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, ard.biesheuvel@linaro.org
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, catalin.marinas@arm.com, sam@ravnborg.org

Hi Will,

 > Damn, I actually prefer the flag :)
 >
 > But actually, if you look at our implementation of vmemmap_populate, 
then we
 > have our own version of vmemmap_populate_basepages that terminates at the
 > pmd level anyway if ARM64_SWAPPER_USES_SECTION_MAPS. If there's 
resistance
 > to do this in the core code, then I'd be inclined to replace our
 > vmemmap_populate implementation in the arm64 code with a single 
version that
 > can terminate at either the PMD or the PTE level, and do zeroing if
 > required. We're already special-casing it, so we don't really lose 
anything
 > imo.

Another approach is to create a new mapping interface for kasan only. As 
what Ard Biesheuvel wrote:

 > KASAN uses vmemmap_populate as a convenience: kasan has nothing to do
 > with vmemmap, but the function already existed and happened to do what
 > KASAN requires.
 >
 > Given that that will no longer be the case, it would be far better to
 > stop using vmemmap_populate altogether, and clone it into a KASAN
 > specific version (with an appropriate name) with the zeroing folded
 > into it.

I agree with this statement, but I think it should not be part of this 
project.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

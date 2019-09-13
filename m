Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA4AFC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:58:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78472208C2
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:58:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78472208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5B5C6B0005; Fri, 13 Sep 2019 02:58:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3B06B0006; Fri, 13 Sep 2019 02:58:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAA916B0007; Fri, 13 Sep 2019 02:58:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 93B656B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:58:14 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 329FC20BDF
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:58:14 +0000 (UTC)
X-FDA: 75928993308.17.house44_81c7727bd8a35
X-HE-Tag: house44_81c7727bd8a35
X-Filterd-Recvd-Size: 3885
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:58:11 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0A928337;
	Thu, 12 Sep 2019 23:58:11 -0700 (PDT)
Received: from [10.162.41.125] (p8cg001049571a15.blr.arm.com [10.162.41.125])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6675F3F67D;
	Fri, 13 Sep 2019 00:00:27 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page
 table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org,
 Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov"
 <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
Message-ID: <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
Date: Fri, 13 Sep 2019 12:28:08 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/13/2019 11:53 AM, Christophe Leroy wrote:
> Fix build failure on powerpc.
> 
> Fix preemption imbalance.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  mm/arch_pgtable_test.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
> index 8b4a92756ad8..f2b3c9ec35fa 100644
> --- a/mm/arch_pgtable_test.c
> +++ b/mm/arch_pgtable_test.c
> @@ -24,6 +24,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/sched/mm.h>
> +#include <linux/highmem.h>

This is okay.

>  #include <asm/pgalloc.h>
>  #include <asm/pgtable.h>
>  
> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
>  	p4d_clear_tests(p4dp);
>  	pgd_clear_tests(mm, pgdp);
>  
> +	pte_unmap(ptep);
> +

Now the preemption imbalance via pte_alloc_map() path i.e

pte_alloc_map() -> pte_offset_map() -> kmap_atomic()

Is not this very much powerpc 32 specific or this will be applicable
for all platform which uses kmap_XXX() to map high memory ?


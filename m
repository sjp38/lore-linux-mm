Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F15B66B000A
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:32:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id d194so3638487ite.5
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:32:52 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0167.hostedemail.com. [216.40.44.167])
        by mx.google.com with ESMTPS id 94si1751144ior.157.2018.02.13.11.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 11:32:52 -0800 (PST)
Message-ID: <1518550368.22190.53.camel@perches.com>
Subject: Re: [PATCH] mm/gup: Fixed coding style error and warnings.
From: Joe Perches <joe@perches.com>
Date: Tue, 13 Feb 2018 11:32:48 -0800
In-Reply-To: <20180213191722.11228-1-marioleinweber@web.de>
References: <20180213191722.11228-1-marioleinweber@web.de>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mario Leinweber <marioleinweber@web.de>, akpm@linux-foundation.org
Cc: mingo@kernel.org, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

You should have a changelog.

On Tue, 2018-02-13 at 14:17 -0500, Mario Leinweber wrote:
[]
> diff --git a/mm/gup.c b/mm/gup.c
[]
> @@ -1635,7 +1640,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  					 PMD_SHIFT, next, write, pages, nr))
>  				return 0;
>  		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
> -				return 0;
> +			return 0;

And of all these changes, this might be the only really useful one
as the
indentation is misleading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

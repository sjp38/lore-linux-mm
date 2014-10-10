Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 237AA6B0038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 10:35:44 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so1757236pdj.18
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 07:35:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tz10si4050799pac.23.2014.10.10.07.35.42
        for <linux-mm@kvack.org>;
        Fri, 10 Oct 2014 07:35:43 -0700 (PDT)
Message-ID: <5437EEA3.50705@intel.com>
Date: Fri, 10 Oct 2014 07:35:15 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] smaps should deal with huge zero page exactly same as
 normal zero page
References: <CADUXgx7QTWBMxesxgCet5rjpGu-V-xK_-5f2rX9R+v-ggi902A@mail.gmail.com> <5436B98E.1070407@intel.com> <20141010132027.GB25038@gmail.com>
In-Reply-To: <20141010132027.GB25038@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengwei Yin <yfw.kernel@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, fengguang.wu@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 10/10/2014 06:21 AM, Fengwei Yin wrote:
> @@ -787,6 +788,9 @@ check_pfn:
>  		return NULL;
>  	}
>  
> +	if (is_huge_zero_pfn(pfn))
> +		return NULL;
> +

That looks a lot better.  One thing, why not put the is_huge_zero_pfn()
check next to the is_zero_pfn() check?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

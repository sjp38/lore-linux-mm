Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CFC156B0069
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 22:14:20 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so2604556pde.14
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 19:14:20 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id xd1si5074129pab.234.2014.10.10.19.14.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Oct 2014 19:14:19 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so2567207pdb.25
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 19:14:19 -0700 (PDT)
Date: Sat, 11 Oct 2014 18:11:02 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH] smaps should deal with huge zero page exactly same as
 normal zero page
Message-ID: <20141011101020.GA26953@gmail.com>
References: <CADUXgx7QTWBMxesxgCet5rjpGu-V-xK_-5f2rX9R+v-ggi902A@mail.gmail.com>
 <5436B98E.1070407@intel.com>
 <20141010132027.GB25038@gmail.com>
 <5437EEA3.50705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5437EEA3.50705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, fengguang.wu@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Oct 10, 2014 at 07:35:15AM -0700, Dave Hansen wrote:
> On 10/10/2014 06:21 AM, Fengwei Yin wrote:
> > @@ -787,6 +788,9 @@ check_pfn:
> >  		return NULL;
> >  	}
> >  
> > +	if (is_huge_zero_pfn(pfn))
> > +		return NULL;
> > +
> 
> That looks a lot better.  One thing, why not put the is_huge_zero_pfn()
> check next to the is_zero_pfn() check?

On the arch which has PTE_SPECIAL feaure, we need to make sure the
is_huge_zero_pfn() is called after the pfn is checked if !pte_special().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

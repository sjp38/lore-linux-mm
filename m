Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB72F6B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 22:49:29 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so4586895pab.24
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 19:49:29 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id lf12si20450659pab.192.2014.10.16.19.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 19:49:28 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so4640032pad.39
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 19:49:28 -0700 (PDT)
Date: Fri, 17 Oct 2014 18:46:01 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH] smaps should deal with huge zero page exactly same as
 normal zero page
Message-ID: <20141017104508.GA24192@gmail.com>
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
Hi,
If no further comment, what's the next step to push this patch merged?
:). Thanks a lot.

Regards
Yin, Fengwei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

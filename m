Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 837826B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:57:55 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id m35so4006988oik.7
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:57:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l56si2167087otb.27.2017.12.01.00.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 00:57:54 -0800 (PST)
Date: Fri, 1 Dec 2017 16:57:49 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH] mm: check pfn_valid first in zero_resv_unavail
Message-ID: <20171201085749.GB2291@dhcp-128-65.nay.redhat.com>
References: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
 <CAOAebxti9DVyjb0dsR-E_8ULenaRf0OZ_WeWxppbdDVmFbt8mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxti9DVyjb0dsR-E_8ULenaRf0OZ_WeWxppbdDVmFbt8mA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/30/17 at 12:25pm, Pavel Tatashin wrote:
> Hi Dave,
> 
> Because unavailable memory can be in the middle of a section, I think
> a proper fix would be to do pfn_valid() check only at the beginning of
> section. Otherwise, we might miss zeroing  a struct page is in the
> middle of a section but pfn_valid() could potentially return false as
> that page is indeed invalid.
> 
> So, I would do something like this:
> +                       if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))
> +                               continue;
> 
> Could you please test if this fix works?

It works.

> 
> We should really look into this memory that is reserved by memblock
> but Linux is not aware of physical backing, so far I know that only
> x86 can have such scenarios, so we should really see if the problem
> can be addressed on x86 platform. It would be very nice if we could
> enforce inside memblock to reserve only memory that has real physical
> backing.

Will resend with your suggestion along with patch log changes.

> 
> Thank you,
> Pavel

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

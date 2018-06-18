Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C461C6B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:14:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x25-v6so8611302pfn.21
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:14:08 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x14-v6si15278656pll.37.2018.06.18.06.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:14:07 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:14:05 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180618131405.ohpxk6sr4zogqmzn@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
 <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
 <20180618100721.qvm4maovfhxbfoo7@black.fi.intel.com>
 <7fab87eb-7b6d-6995-b6c6-46c0fd049d2a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fab87eb-7b6d-6995-b6c6-46c0fd049d2a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 18, 2018 at 12:54:29PM +0000, Dave Hansen wrote:
> On 06/18/2018 03:07 AM, Kirill A. Shutemov wrote:
> > On Wed, Jun 13, 2018 at 06:20:10PM +0000, Dave Hansen wrote:
> >>> +int page_keyid(const struct page *page)
> >>> +{
> >>> +	if (mktme_status != MKTME_ENABLED)
> >>> +		return 0;
> >>> +
> >>> +	return lookup_page_ext(page)->keyid;
> >>> +}
> >>> +EXPORT_SYMBOL(page_keyid);
> >> Please start using a proper X86_FEATURE_* flag for this.  It will give
> >> you all the fancy static patching that you are missing by doing it this way.
> > There's no MKTME CPU feature.
> 
> Right.  We have tons of synthetic features that have no basis in the
> hardware CPUID feature.
> 
> > Well, I guess we can invent syntactic one or just use static key directly.
> 
> Did you mean synthetic?

Right.

> > Let's see how it behaves performance-wise before optimizing this.
> 
> It's not an optimization, it's how we do things in arch/x86, and it has
> a *ton* of optimization infrastructure behind it that you get for free
> if you use it.
> 
> I'm just trying to save Thomas's tired fingers from having to say the
> same thing in a week or two when he looks at this.

Okay, I'll look into this.

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0743C6B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:07:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d4-v6so1653324pfn.9
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 03:07:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q1-v6si12056977pgs.441.2018.06.18.03.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 03:07:24 -0700 (PDT)
Date: Mon, 18 Jun 2018 13:07:21 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180618100721.qvm4maovfhxbfoo7@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
 <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:20:10PM +0000, Dave Hansen wrote:
> > +int page_keyid(const struct page *page)
> > +{
> > +	if (mktme_status != MKTME_ENABLED)
> > +		return 0;
> > +
> > +	return lookup_page_ext(page)->keyid;
> > +}
> > +EXPORT_SYMBOL(page_keyid);
> 
> Please start using a proper X86_FEATURE_* flag for this.  It will give
> you all the fancy static patching that you are missing by doing it this way.

There's no MKTME CPU feature.

Well, I guess we can invent syntactic one or just use static key directly.

Let's see how it behaves performance-wise before optimizing this.

-- 
 Kirill A. Shutemov

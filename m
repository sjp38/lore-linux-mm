Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A63D6B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 08:44:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p2so2729767wre.19
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 05:44:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y43sor3527000ede.20.2018.03.29.05.44.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 05:44:15 -0700 (PDT)
Date: Thu, 29 Mar 2018 15:43:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 12/14] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180329124338.vxzjpkz3ecyor5uc@node.shutemov.name>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-13-kirill.shutemov@linux.intel.com>
 <b4498b2b-5092-b347-e92d-6ebd375fd947@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4498b2b-5092-b347-e92d-6ebd375fd947@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 09:59:23AM -0700, Dave Hansen wrote:
> On 03/28/2018 09:55 AM, Kirill A. Shutemov wrote:
> > +static inline int page_keyid(struct page *page)
> > +{
> > +	if (!mktme_nr_keyids)
> > +		return 0;
> > +
> > +	return lookup_page_ext(page)->keyid;
> > +}
> 
> This doesn't look very optimized.  Don't we normally try to use
> X86_FEATURE_* for these checks so that we get the runtime patching *and*
> compile-time optimizations?

I didn't go to micro optimization just yet. I would like to see whole
stack functioning first.

It doesn't make sense to use cpu_feature_enabledX86_FEATURE_TME) as it
would produce false-positives: MKTME enumeration requires MSR read.

We may change mktme_nr_keyids check to a static key here. But this is not
urgent.

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3BF6B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:45:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e1-v6so13239834pld.23
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:45:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 83-v6sor2249149pge.395.2018.07.23.02.45.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 02:45:29 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:45:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 10/19] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180723094517.7sxt62p3h75htppw@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-11-kirill.shutemov@linux.intel.com>
 <2166be55-3491-f620-5eb0-6f671a53645f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2166be55-3491-f620-5eb0-6f671a53645f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Schofield, Alison" <alison.schofield@intel.com>

On Wed, Jul 18, 2018 at 04:38:02PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > Store KeyID in bits 31:16 of extended page flags. These bits are unused.
> 
> I'd love a two sentence remind of what page_ext is and why you chose to
> use it.  Yes, you need this.  No, not everybody that you want to review
> this patch set knows what it is or why you chose it.

Okay.

> > page_keyid() returns zero until page_ext is ready.
> 
> Is there any implication of this?  Or does it not matter because we
> don't run userspace until after page_ext initialization is done?

It matters in sense that we shouldn't reference page_ext before it's
initialized otherwise we will get garbage and crash.

> > page_ext initializer enables static branch to indicate that
> 
> 			"enables a static branch"
> 
> > page_keyid() can use page_ext. The same static branch will gate MKTME
> > readiness in general.
> 
> Can you elaborate on this a bit?  It would also be a nice place to hint
> to the folks working hard on the APIs to ensure she checks this.

Okay.

> > We don't yet set KeyID for the page. It will come in the following
> > patch that implements prep_encrypted_page(). All pages have KeyID-0 for
> > now.
> 
> It also wouldn't hurt to mention why you don't use an X86_FEATURE_* for
> this rather than an explicit static branch.  I'm sure the x86
> maintainers will be curious.

Sure.

-- 
 Kirill A. Shutemov

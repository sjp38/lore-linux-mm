Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FEF46B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:59:33 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t17-v6so9989076ply.13
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 03:59:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a80-v6si15072207pfg.200.2018.06.18.03.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 03:59:32 -0700 (PDT)
Date: Mon, 18 Jun 2018 13:59:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 12/17] x86/mm: Allow to disable MKTME after enumeration
Message-ID: <20180618105928.oblisvtr2cpitilj@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-13-kirill.shutemov@linux.intel.com>
 <13ba89bb-9df3-6272-96ea-005200c3198f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13ba89bb-9df3-6272-96ea-005200c3198f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:30:02PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Separate MKTME enumaration from enabling. We need to postpone enabling
> > until initialization is complete.
> 
> 	         ^ enumeration

Nope.

I want to differentiate enumeration in detect_tme() and the point where
MKTME is usable: after mktme_init().

> > The new helper mktme_disable() allows to disable MKTME even if it's
> 
> s/to disable/disabling/

> > enumerated successfully. MKTME initialization may fail and this
> > functionallity allows system to boot regardless of the failure.
> 
> What can make it fail?

I'll add this to commit message:

MKTME needs per-KeyID direct mapping. It requires a lot more virtual
address space which may be a problem in 4-level paging mode. If the
system has more physical memory than we can handle with MKTME.
The feature allows to fail MKTME, but boot the system successfully.

-- 
 Kirill A. Shutemov

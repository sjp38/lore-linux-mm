Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2BB36B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:18:06 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c3-v6so2020434plz.7
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:18:06 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f192-v6si3729687pfa.252.2018.06.13.13.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:18:05 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:18:02 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 02/17] mm/khugepaged: Do not collapse pages in
 encrypted VMAs
Message-ID: <20180613201802.45m2745soztmkxmp@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
 <f0e4648f-a458-856e-8a06-d186c280530a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0e4648f-a458-856e-8a06-d186c280530a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 05:50:24PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Pages for encrypted VMAs have to be allocated in a special way:
> > we would need to propagate down not only desired NUMA node but also
> > whether the page is encrypted.
> > 
> > It complicates not-so-trivial routine of huge page allocation in
> > khugepaged even more. It also puts more pressure on page allocator:
> > we cannot re-use pages allocated for encrypted VMA to collapse
> > page in unencrypted one or vice versa.
> > 
> > I think for now it worth skipping encrypted VMAs. We can return
> > to this topic later.
> 
> You're asking for this to be included, but without a major piece of THP
> support.  Is THP support unimportant for this feature?
> 
> Are we really asking the x86 maintainers to merge this feature with this
> restriction in place?

I gave it more thought after your comment and I think I see a way to get
khugepaged work with memory encryption.

Let me check it tomorrow.

-- 
 Kirill A. Shutemov

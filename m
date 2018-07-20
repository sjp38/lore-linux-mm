Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17E636B0007
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:25:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m25-v6so5845211pgv.22
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:25:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g1-v6sor585198plt.145.2018.07.20.05.25.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:25:21 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:25:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 05/19] mm/page_alloc: Handle allocation for encrypted
 memory
Message-ID: <20180720122516.zm35yk4r4tcy752s@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-6-kirill.shutemov@linux.intel.com>
 <95ce19cb-332c-44f5-b3a1-6cfebd870127@intel.com>
 <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
 <b0a92a2f-cf14-c976-9fbd-fd9aa4ebcf96@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0a92a2f-cf14-c976-9fbd-fd9aa4ebcf96@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 07:05:36AM -0700, Dave Hansen wrote:
> On 07/19/2018 01:27 AM, Kirill A. Shutemov wrote:
> >> What other code might need prep_encrypted_page()?
> > 
> > Custom pages allocators if these pages can end up in encrypted VMAs.
> > 
> > It this case compaction creates own pool of pages to be used for
> > allocation during page migration.
> 
> OK, that makes sense.  It also sounds like some great information to add
> near prep_encrypted_page().

Okay.

> Do we have any ability to catch cases like this if we get them wrong, or
> will we just silently corrupt data?

I cannot come up with any reasonable way to detect this immediately.
I'll think about this more.

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99ADC6B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:22:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u130-v6so3223249pgc.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:22:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s22-v6sor691751plr.116.2018.07.19.00.22.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 00:22:33 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:16:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 02/19] mm: Do not use zero page in encrypted pages
Message-ID: <20180719071606.dkeq5btz5wlzk4oq@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
 <e09c67ab-38a7-5b76-29e6-a45627eec1e5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e09c67ab-38a7-5b76-29e6-a45627eec1e5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 10:36:24AM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > Zero page is not encrypted and putting it into encrypted VMA produces
> > garbage.
> > 
> > We can map zero page with KeyID-0 into an encrypted VMA, but this would
> > be violation security boundary between encryption domains.
> 
> Why?  How is it a violation?
> 
> It only matters if they write secrets.  They can't write secrets to the
> zero page.

I believe usage of zero page is wrong here. It would indirectly reveal
content of supposedly encrypted memory region.

I can see argument why it should be okay and I don't have very strong
opinion on this.

If folks see it's okay to use zero page in encrypted VMAs I can certainly
make it work.

> Is this only because you accidentally inherited ->vm_page_prot on the
> zero page PTE?

Yes, in previous patchset I mapped zero page with wrong KeyID. This is one
of possible fixes for this.

-- 
 Kirill A. Shutemov

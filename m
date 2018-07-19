Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B19366B0005
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:54:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t26-v6so3829801pfh.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 02:54:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f70-v6sor1619165pfd.104.2018.07.19.02.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 02:54:11 -0700 (PDT)
Date: Thu, 19 Jul 2018 12:54:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 07/19] x86/mm: Mask out KeyID bits from page table
 entry pfn
Message-ID: <20180719095404.pkm72iyhhc6v5tth@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-8-kirill.shutemov@linux.intel.com>
 <9922042b-f130-a87c-8239-9b852e335f26@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9922042b-f130-a87c-8239-9b852e335f26@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:13:20PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > +	} else {
> > +		/*
> > +		 * Reset __PHYSICAL_MASK.
> > +		 * Maybe needed if there's inconsistent configuation
> > +		 * between CPUs.
> > +		 */
> > +		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > +	}
> 
> This seems like an appropriate place for a WARN_ON().  Either that, or
> axe this code.

There's pr_err_once() above in the function.

-- 
 Kirill A. Shutemov

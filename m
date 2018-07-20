Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 593306B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:31:44 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so7296672plo.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:31:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17-v6sor490572pfb.98.2018.07.20.05.31.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:31:43 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:31:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 07/19] x86/mm: Mask out KeyID bits from page table
 entry pfn
Message-ID: <20180720123139.2k3tze6rrfnkhksx@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-8-kirill.shutemov@linux.intel.com>
 <9922042b-f130-a87c-8239-9b852e335f26@intel.com>
 <20180719095404.pkm72iyhhc6v5tth@kshutemo-mobl1>
 <0c1bdd80-8e47-e65c-f421-0c5010058025@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c1bdd80-8e47-e65c-f421-0c5010058025@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 07:19:01AM -0700, Dave Hansen wrote:
> On 07/19/2018 02:54 AM, Kirill A. Shutemov wrote:
> > On Wed, Jul 18, 2018 at 04:13:20PM -0700, Dave Hansen wrote:
> >> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> >>> +	} else {
> >>> +		/*
> >>> +		 * Reset __PHYSICAL_MASK.
> >>> +		 * Maybe needed if there's inconsistent configuation
> >>> +		 * between CPUs.
> >>> +		 */
> >>> +		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> >>> +	}
> >> This seems like an appropriate place for a WARN_ON().  Either that, or
> >> axe this code.
> > There's pr_err_once() above in the function.
> 
> Do you mean for the (tme_activate != tme_activate_cpu0) check?
> 
> But that's about double-activating this feature.  This check is about an
> inconsistent configuration between two CPUs which seems totally different.
> 
> Could you explain?

(tme_activate != tme_activate_cpu0) check is about inconsistent
configuration. It checks if MSR's content on the given CPU matches MSR on
CPU0.

-- 
 Kirill A. Shutemov

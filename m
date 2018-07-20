Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA6416B0271
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:34:58 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so7297037plv.0
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor612410plv.44.2018.07.20.05.34.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:34:57 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:34:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
Message-ID: <20180720123453.sqz6w5ihaw7gvnoo@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
 <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com>
 <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
 <e56be94d-e70e-8100-9b15-98a224442db9@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e56be94d-e70e-8100-9b15-98a224442db9@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 07:23:27AM -0700, Dave Hansen wrote:
> On 07/19/2018 03:21 AM, Kirill A. Shutemov wrote:
> > On Wed, Jul 18, 2018 at 04:19:10PM -0700, Dave Hansen wrote:
> >> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> >>> mktme_nr_keyids holds number of KeyIDs available for MKTME, excluding
> >>> KeyID zero which used by TME. MKTME KeyIDs start from 1.
> >>>
> >>> mktme_keyid_shift holds shift of KeyID within physical address.
> >> I know what all these words mean, but the combination of them makes no
> >> sense to me.  I still don't know what the variable does after reading this.
> >>
> >> Is this the lowest bit in the physical address which is used for the
> >> KeyID?  How many bits you must shift up a KeyID to get to the location
> >> at which it can be masked into the physical address?
> > Right.
> > 
> > I'm not sure what is not clear from the description. It look fine to me.
> 
> Well, OK, I guess I can write a better one for you.
> 
> "Position in the PTE of the lowest bit of the KeyID"
> 
> It's also a name that could use some love (now that I know what it
> does).  mktme_keyid_pte_shift would be much better.  Or
> mktme_keyid_low_pte_bit.

Okay, thanks.

-- 
 Kirill A. Shutemov

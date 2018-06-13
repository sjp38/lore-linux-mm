Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50B076B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:38:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a12-v6so1812468pfn.12
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:38:09 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d37-v6si902411plb.481.2018.06.13.13.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:38:08 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:38:04 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 02/17] mm/khugepaged: Do not collapse pages in
 encrypted VMAs
Message-ID: <20180613203804.bpeipe4txckja6na@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
 <f0e4648f-a458-856e-8a06-d186c280530a@intel.com>
 <20180613201802.45m2745soztmkxmp@black.fi.intel.com>
 <7dccd52e-ca46-b417-5a7b-274dc7ff3e44@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7dccd52e-ca46-b417-5a7b-274dc7ff3e44@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 08:20:28PM +0000, Dave Hansen wrote:
> On 06/13/2018 01:18 PM, Kirill A. Shutemov wrote:
> >> Are we really asking the x86 maintainers to merge this feature with this
> >> restriction in place?
> > I gave it more thought after your comment and I think I see a way to get
> > khugepaged work with memory encryption.
> 
> So should folks be reviewing this set, or skip it an wait on your new set?

You gave me fair bit of feedback to work on, but AFAICS it doesn't change
anything fundamentally.

More feedback is welcome.

-- 
 Kirill A. Shutemov

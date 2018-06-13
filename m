Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC6F6B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:31:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e2-v6so1252772pgq.4
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:31:12 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t7-v6si3007346pgb.295.2018.06.13.13.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:31:11 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:31:08 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
Message-ID: <20180613203108.k63fda4hvsqyczw7@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
 <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 05:51:50PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Pages encrypted with different encryption keys are not subject to KSM
> > merge. Otherwise it would cross security boundary.
> 
> This needs a much stronger explanation.

Okay, fair enough.

> Which KeyID would be used for access in the new direct mappings?

New direct mapping?

Pages would be compared using direct mappings relevant for their KeyID.
They will be threated as identical if they plain-text is identical.

> What actually happens without this patch in place?

One of processes would get the page mapped with wrong KeyID and see
garbage. We setup mapping according to KeyID in vma->vm_page_prot.

-- 
 Kirill A. Shutemov

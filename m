Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A87886B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:55:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e1-v6so3715306pgp.20
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 13:55:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i61-v6si8751776plb.138.2018.06.15.13.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 13:55:38 -0700 (PDT)
Date: Fri, 15 Jun 2018 23:55:36 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20180615205535.32nhgqelbyjihzts@black.fi.intel.com>
References: <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
 <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
 <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
 <645a4ca8-ae77-dcdd-0cbc-0da467fc210d@intel.com>
 <20180615152731.3y6rre7g66rmncxr@black.fi.intel.com>
 <cbca7e78-d70b-3eae-1c73-6ad859661b8a@intel.com>
 <20180615160613.arntdivl5gdpfwfw@black.fi.intel.com>
 <445af5b3-eaca-0589-8899-88a3b26fb509@intel.com>
 <20180615204512.axt2avr4ysc2iyrp@black.fi.intel.com>
 <c9645eb2-2223-b374-1e30-2c5566ff73c6@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9645eb2-2223-b374-1e30-2c5566ff73c6@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 15, 2018 at 08:45:21PM +0000, Dave Hansen wrote:
> On 06/15/2018 01:45 PM, Kirill A. Shutemov wrote:
> > On Fri, Jun 15, 2018 at 04:58:24PM +0000, Dave Hansen wrote:
> >> On 06/15/2018 09:06 AM, Kirill A. Shutemov wrote:
> >>> I have no idea what such concept should be called. I cannot come with
> >>> anything better than PTE_PFN_MASK_MAX. Do you?
> >> PTE_PRESERVE_MASK
> >>
> >> Or maybe:
> >>
> >> PTE_MODIFY_PRESERVE_MASK
> > It just replacing one confusion with another. Preserve what?
> 
> "Preserve this mask when modifying pte permission bits"

We preserve more than these bits. See _PAGE_CHG_MASK.

-- 
 Kirill A. Shutemov

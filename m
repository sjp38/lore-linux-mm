Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52D7A6B0006
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:41:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o7-v6so1242217pgc.23
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:41:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 3-v6si3610343plp.515.2018.06.13.13.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:41:37 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:41:34 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
Message-ID: <20180613204134.voy7iimrlcywblnx@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
 <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
 <20180613203108.k63fda4hvsqyczw7@black.fi.intel.com>
 <355d6b1f-9188-e93b-9cf1-01ece1879cad@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <355d6b1f-9188-e93b-9cf1-01ece1879cad@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 08:35:46PM +0000, Dave Hansen wrote:
> On 06/13/2018 01:31 PM, Kirill A. Shutemov wrote:
> >> What actually happens without this patch in place?
> > 
> > One of processes would get the page mapped with wrong KeyID and see
> > garbage. 
> 
> OK, but what about two pages with the same KeyID?  It's actually totally
> possible for KSM to determine that two pages have the same plaintext and
> merge them.  Why don't we do that?

That's exactly what we do :)

> > We setup mapping according to KeyID in vma->vm_page_prot.
> 
> Then why do we bother with page_keyid() and the page_ext stuff?

VMA is not always around.

Using KeyID in vma->vm_page_prot we don't need to change anything in PTE
setup functions. It just works.

-- 
 Kirill A. Shutemov

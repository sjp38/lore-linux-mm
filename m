Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8046B0006
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:48:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j4-v6so559062pgq.16
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:48:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z33-v6sor5444016plb.77.2018.07.10.03.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 03:48:14 -0700 (PDT)
Date: Tue, 10 Jul 2018 13:48:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 07/18] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
Message-ID: <20180710104809.pigivw4n4yuehdpo@kshutemo-mobl1>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-8-kirill.shutemov@linux.intel.com>
 <20180709180949.GH6873@char.US.ORACLE.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709180949.GH6873@char.US.ORACLE.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 09, 2018 at 02:09:49PM -0400, Konrad Rzeszutek Wilk wrote:
> > diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> > index 4b101dd6e52f..4ebee899c363 100644
> > --- a/arch/x86/mm/Makefile
> > +++ b/arch/x86/mm/Makefile
> > @@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
> > +
> > +obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
> 
> Any particular reason to have x86 in the CONFIG?

It is consistent with MPX and protection keys.

-- 
 Kirill A. Shutemov

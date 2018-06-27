Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CEA4A6B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:57:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 39-v6so1874057ple.6
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:57:31 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a8-v6si4777769pfj.300.2018.06.27.14.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 14:57:30 -0700 (PDT)
Date: Thu, 28 Jun 2018 00:57:26 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
Message-ID: <20180627215726.l5syzdcc26hgihtt@black.fi.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
 <ecf92475-93b4-295c-f1fc-7efba4843d98@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ecf92475-93b4-295c-f1fc-7efba4843d98@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 05:30:12PM +0000, Randy Dunlap wrote:
> On 06/26/2018 07:22 AM, Kirill A. Shutemov wrote:
> > Add new config option to enabled/disable Multi-Key Total Memory
> > Encryption support.
> > 
> > MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> > direct mappings for memory hotplug.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/Kconfig | 19 ++++++++++++++++++-
> >  1 file changed, 18 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index fa5e1ec09247..9a843bd63108 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -1523,6 +1523,23 @@ config ARCH_USE_MEMREMAP_PROT
> >  	def_bool y
> >  	depends on AMD_MEM_ENCRYPT
> >  
> > +config X86_INTEL_MKTME
> > +	bool "Intel Multi-Key Total Memory Encryption"
> > +	select DYNAMIC_PHYSICAL_MASK
> > +	select PAGE_EXTENSION
> > +	depends on X86_64 && CPU_SUP_INTEL
> > +	---help---
> > +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> > +	  This requires an Intel processor that has support of the feature.
> > +
> > +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> > +	  transparent memory encryption in and upcoming Intel platforms.
> 
> huh?  Maybe drop the "and"?

Ugh.. It has to be "an".

-- 
 Kirill A. Shutemov

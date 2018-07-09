Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8B236B032F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:52:55 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id r131-v6so16320257ith.9
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:52:55 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b189-v6si10961025iti.30.2018.07.09.11.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:52:54 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:52:46 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
Message-ID: <20180709185246.GC17368@char.us.oracle.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
 <20180709183656.GK6873@char.US.ORACLE.com>
 <d9edff3d-64bd-be81-c9fd-52699d7da81e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9edff3d-64bd-be81-c9fd-52699d7da81e@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 09, 2018 at 11:44:33AM -0700, Dave Hansen wrote:
> On 07/09/2018 11:36 AM, Konrad Rzeszutek Wilk wrote:
> > On Tue, Jun 26, 2018 at 05:22:45PM +0300, Kirill A. Shutemov wrote:
> > Rip out the X86?
> >> +	bool "Intel Multi-Key Total Memory Encryption"
> >> +	select DYNAMIC_PHYSICAL_MASK
> >> +	select PAGE_EXTENSION
> > 
> > And maybe select 5-page?
> 
> Why?  It's not a strict dependency.  You *can* build a 4-level kernel
> and run it on smaller systems.

Sure, but in one of his commits he mentions that we may run in overlapping
physical memory if we use 4-level paging. Hence why not just move to 5-level
paging and simplify this.
> 
> >> +	depends on X86_64 && CPU_SUP_INTEL
> >> +	---help---
> >> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> >> +	  This requires an Intel processor that has support of the feature.
> >> +
> >> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> >> +	  transparent memory encryption in and upcoming Intel platforms.
> > 
> > How about saying which CPUs? Or just dropping this?
> 
> We don't have any information about specifically which processors with
> have this feature to share.  But, this config text does tell someone
> that they can't use this feature on today's platforms.
> 
> We _did_ say this for previous features (protection keys stands out
> where we said it was for "Skylake Servers" IIRC), but we are not yet
> able to do the same for this feature.

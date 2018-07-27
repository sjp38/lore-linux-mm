Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFB16B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:49:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j4-v6so2980955pgq.16
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 06:49:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3-v6sor1279693plb.139.2018.07.27.06.49.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 06:49:46 -0700 (PDT)
Date: Fri, 27 Jul 2018 16:49:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 18/19] x86/mm: Handle encrypted memory in
 page_to_virt() and __pa()
Message-ID: <20180727134941.mljg2biwughv2yhr@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-19-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.21.1807182356520.1689@nanos.tec.linutronix.de>
 <20180723101201.wjbaktmerx3yiocd@kshutemo-mobl1>
 <9966c343-1247-b505-b736-b06509e15d10@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9966c343-1247-b505-b736-b06509e15d10@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 26, 2018 at 10:26:23AM -0700, Dave Hansen wrote:
> On 07/23/2018 03:12 AM, Kirill A. Shutemov wrote:
> > page_to_virt() definition overwrites default macros provided by
> > <linux/mm.h>. We only overwrite the macros if MTKME is enabled
> > compile-time.
> 
> Can you remind me why we need this in page_to_virt() as opposed to in
> the kmap() code?  Is it because we have lots of 64-bit code that doesn't
> use kmap() or something?

I just found it most suitable. It should cover all cases, even if kmap()
is not used.

-- 
 Kirill A. Shutemov

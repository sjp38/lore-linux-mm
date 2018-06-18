Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 283AE6B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:41:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n3-v6so5225282pgp.21
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:41:04 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bi1-v6si14618241plb.126.2018.06.18.06.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:41:03 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:41:00 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 17/17] x86: Introduce CONFIG_X86_INTEL_MKTME
Message-ID: <20180618134100.iehlv2uw4n7ariro@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-18-kirill.shutemov@linux.intel.com>
 <43ea6cea-b88c-e08a-3f4e-64c39b20ae59@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43ea6cea-b88c-e08a-3f4e-64c39b20ae59@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:46:34PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Add new config option to enabled/disable Multi-Key Total Memory
> > Encryption support.
> > 
> > MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> > direct mappings for memory hotplug.
> 
> Isn't it really *the* direct mapping primarily?  We make all of them
> larger, but the direct mapping is impacted too.  This makes it sound
> like it applies only to the MKTME mappings.

We only cares about the padding in two cases: MKTME and KALSR.
If none of them enabled padding doesn't have meaning. We have PAGE_OFFSET
at fixed address and size is also fixed.

-- 
 Kirill A. Shutemov

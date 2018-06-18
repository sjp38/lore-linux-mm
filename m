Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1C7C6B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 08:54:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l2-v6so5036622pff.3
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:54:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c17-v6si14027014pfi.102.2018.06.18.05.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 05:54:31 -0700 (PDT)
Subject: Re: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
 <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
 <20180618100721.qvm4maovfhxbfoo7@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7fab87eb-7b6d-6995-b6c6-46c0fd049d2a@intel.com>
Date: Mon, 18 Jun 2018 05:54:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180618100721.qvm4maovfhxbfoo7@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/18/2018 03:07 AM, Kirill A. Shutemov wrote:
> On Wed, Jun 13, 2018 at 06:20:10PM +0000, Dave Hansen wrote:
>>> +int page_keyid(const struct page *page)
>>> +{
>>> +	if (mktme_status != MKTME_ENABLED)
>>> +		return 0;
>>> +
>>> +	return lookup_page_ext(page)->keyid;
>>> +}
>>> +EXPORT_SYMBOL(page_keyid);
>> Please start using a proper X86_FEATURE_* flag for this.  It will give
>> you all the fancy static patching that you are missing by doing it this way.
> There's no MKTME CPU feature.

Right.  We have tons of synthetic features that have no basis in the
hardware CPUID feature.

> Well, I guess we can invent syntactic one or just use static key directly.

Did you mean synthetic?

> Let's see how it behaves performance-wise before optimizing this.

It's not an optimization, it's how we do things in arch/x86, and it has
a *ton* of optimization infrastructure behind it that you get for free
if you use it.

I'm just trying to save Thomas's tired fingers from having to say the
same thing in a week or two when he looks at this.

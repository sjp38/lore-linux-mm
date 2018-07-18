Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCB76B0270
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:38:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x15-v6so3363571pll.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:38:12 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e6-v6si4530526pgh.50.2018.07.18.16.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:38:11 -0700 (PDT)
Subject: Re: [PATCHv5 10/19] x86/mm: Implement page_keyid() using page_ext
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-11-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2166be55-3491-f620-5eb0-6f671a53645f@intel.com>
Date: Wed, 18 Jul 2018 16:38:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-11-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Schofield, Alison" <alison.schofield@intel.com>

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> Store KeyID in bits 31:16 of extended page flags. These bits are unused.

I'd love a two sentence remind of what page_ext is and why you chose to
use it.  Yes, you need this.  No, not everybody that you want to review
this patch set knows what it is or why you chose it.

> page_keyid() returns zero until page_ext is ready.

Is there any implication of this?  Or does it not matter because we
don't run userspace until after page_ext initialization is done?

> page_ext initializer enables static branch to indicate that

			"enables a static branch"

> page_keyid() can use page_ext. The same static branch will gate MKTME
> readiness in general.

Can you elaborate on this a bit?  It would also be a nice place to hint
to the folks working hard on the APIs to ensure she checks this.

> We don't yet set KeyID for the page. It will come in the following
> patch that implements prep_encrypted_page(). All pages have KeyID-0 for
> now.

It also wouldn't hurt to mention why you don't use an X86_FEATURE_* for
this rather than an explicit static branch.  I'm sure the x86
maintainers will be curious.

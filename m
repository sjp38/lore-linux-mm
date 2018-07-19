Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF0B76B0275
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 20:01:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t26-v6so3058286pfh.0
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 17:01:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12-v6si1948842plo.475.2018.07.18.17.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 17:01:41 -0700 (PDT)
Subject: Re: [PATCHv5 17/19] x86/mm: Implement sync_direct_mapping()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-18-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4a99e079-7bd0-a611-571a-d730815b4b2a@intel.com>
Date: Wed, 18 Jul 2018 17:01:37 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-18-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
>  arch/x86/include/asm/mktme.h |   8 +
>  arch/x86/mm/init_64.c        |  10 +
>  arch/x86/mm/mktme.c          | 437 +++++++++++++++++++++++++++++++++++
>  3 files changed, 455 insertions(+)

I'm not the maintainer.  But, NAK from me on this on the diffstat alone.

There is simply too much technical debt here.  There is no way this code
is not riddled with bugs and I would bet lots of beer on the fact that
this has received little to know testing with all the combinations that
matter, like memory hotplug.  I'd love to be proven wrong, so I eagerly
await to be dazzled with the test results that have so far escaped
mention in the changelog.

Please make an effort to refactor this to reuse the code that we already
have to manage the direct mapping.  We can't afford 455 new lines of
page table manipulation that nobody tests or runs.

How _was_ this tested?

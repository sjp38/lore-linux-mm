Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4899E6B026F
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:41:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q18-v6so1910394pll.3
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:41:23 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c8-v6si2726068pgv.443.2018.06.13.11.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:41:22 -0700 (PDT)
Subject: Re: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <41c9db7f-2277-4403-5556-df56b686d5c8@intel.com>
Date: Wed, 13 Jun 2018 11:41:21 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
>  arch/x86/include/asm/mktme.h |   6 +
>  arch/x86/mm/init_64.c        |   6 +
>  arch/x86/mm/mktme.c          | 444 +++++++++++++++++++++++++++++++++++
>  3 files changed, 456 insertions(+)

Can we not do any better than 400 lines of new open-coded pagetable
hacking?

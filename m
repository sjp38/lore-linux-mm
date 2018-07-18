Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E70D6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:43:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e19-v6so2304592pgv.11
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:43:12 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b1-v6si3599674plc.403.2018.07.18.10.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 10:43:11 -0700 (PDT)
Subject: Re: [PATCHv5 04/19] mm/page_alloc: Unify alloc_hugepage_vma()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-5-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9a716ae8-c4bd-59d8-f8d3-7816fb58fabe@intel.com>
Date: Wed, 18 Jul 2018 10:43:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-5-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A grammar error or two is probably OK in these descriptions, but these
are just riddled with them in a way that makes them hard to read.
Suggestions below.

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> We don't need to have separate implementations of alloc_hugepage_vma()
> for NUMA and non-NUMA. Using variant based on alloc_pages_vma() we would
> cover both cases.

"Using the"

> This is preparation patch for allocation encrypted pages.

"a preparation"

"allocation encrypted pages" -> "allocation of encrypted pages" or
"allocation encrypted pages" -> "allocating encrypted pages" or

> alloc_pages_vma() will handle allocation of encrypted pages. With this
> change we don' t need to cover alloc_hugepage_vma() separately.

"don' t" -> "don't"

> The change makes typo in Alpha's implementation of

"a typo"

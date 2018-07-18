Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2026B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:13:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so2656720pgp.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:13:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d21-v6si4597113pgn.222.2018.07.18.16.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:13:23 -0700 (PDT)
Subject: Re: [PATCHv5 07/19] x86/mm: Mask out KeyID bits from page table entry
 pfn
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-8-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9922042b-f130-a87c-8239-9b852e335f26@intel.com>
Date: Wed, 18 Jul 2018 16:13:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-8-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> +	} else {
> +		/*
> +		 * Reset __PHYSICAL_MASK.
> +		 * Maybe needed if there's inconsistent configuation
> +		 * between CPUs.
> +		 */
> +		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +	}

This seems like an appropriate place for a WARN_ON().  Either that, or
axe this code.

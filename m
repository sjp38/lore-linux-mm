Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 528F96B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:19:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n19-v6so3753347pgv.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:19:10 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 190-v6si6506467pfu.343.2018.07.19.07.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:19:09 -0700 (PDT)
Subject: Re: [PATCHv5 07/19] x86/mm: Mask out KeyID bits from page table entry
 pfn
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-8-kirill.shutemov@linux.intel.com>
 <9922042b-f130-a87c-8239-9b852e335f26@intel.com>
 <20180719095404.pkm72iyhhc6v5tth@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0c1bdd80-8e47-e65c-f421-0c5010058025@intel.com>
Date: Thu, 19 Jul 2018 07:19:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180719095404.pkm72iyhhc6v5tth@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/19/2018 02:54 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 04:13:20PM -0700, Dave Hansen wrote:
>> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
>>> +	} else {
>>> +		/*
>>> +		 * Reset __PHYSICAL_MASK.
>>> +		 * Maybe needed if there's inconsistent configuation
>>> +		 * between CPUs.
>>> +		 */
>>> +		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>>> +	}
>> This seems like an appropriate place for a WARN_ON().  Either that, or
>> axe this code.
> There's pr_err_once() above in the function.

Do you mean for the (tme_activate != tme_activate_cpu0) check?

But that's about double-activating this feature.  This check is about an
inconsistent configuration between two CPUs which seems totally different.

Could you explain?

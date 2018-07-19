Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70D496B0270
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:23:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o16-v6so3754192pgv.21
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:23:36 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 64-v6si5891116pfd.155.2018.07.19.07.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:23:35 -0700 (PDT)
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
 <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com>
 <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e56be94d-e70e-8100-9b15-98a224442db9@intel.com>
Date: Thu, 19 Jul 2018 07:23:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/19/2018 03:21 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 04:19:10PM -0700, Dave Hansen wrote:
>> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
>>> mktme_nr_keyids holds number of KeyIDs available for MKTME, excluding
>>> KeyID zero which used by TME. MKTME KeyIDs start from 1.
>>>
>>> mktme_keyid_shift holds shift of KeyID within physical address.
>> I know what all these words mean, but the combination of them makes no
>> sense to me.  I still don't know what the variable does after reading this.
>>
>> Is this the lowest bit in the physical address which is used for the
>> KeyID?  How many bits you must shift up a KeyID to get to the location
>> at which it can be masked into the physical address?
> Right.
> 
> I'm not sure what is not clear from the description. It look fine to me.

Well, OK, I guess I can write a better one for you.

"Position in the PTE of the lowest bit of the KeyID"

It's also a name that could use some love (now that I know what it
does).  mktme_keyid_pte_shift would be much better.  Or
mktme_keyid_low_pte_bit.

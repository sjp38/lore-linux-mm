Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9BD26B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:40:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s7-v6so1833720pfm.4
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:40:50 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q18-v6si3025651pgd.294.2018.06.13.13.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:40:49 -0700 (PDT)
Subject: Re: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
From: Dave Hansen <dave.hansen@intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
 <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
 <20180613203108.k63fda4hvsqyczw7@black.fi.intel.com>
 <355d6b1f-9188-e93b-9cf1-01ece1879cad@intel.com>
Message-ID: <2fd62aa9-968d-c547-a509-dad3b28019ce@intel.com>
Date: Wed, 13 Jun 2018 13:40:48 -0700
MIME-Version: 1.0
In-Reply-To: <355d6b1f-9188-e93b-9cf1-01ece1879cad@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/13/2018 01:35 PM, Dave Hansen wrote:
> On 06/13/2018 01:31 PM, Kirill A. Shutemov wrote:
>>> What actually happens without this patch in place?
>> One of processes would get the page mapped with wrong KeyID and see
>> garbage. 
> OK, but what about two pages with the same KeyID?  It's actually totally
> possible for KSM to determine that two pages have the same plaintext and
> merge them.  Why don't we do that?

/me goes back to look at the patch... which is doing exactly that

But, this still needs a stronger explanation of what goes wrong if this
patch is not in place.

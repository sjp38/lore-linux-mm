Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFE36B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:35:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n3-v6so1244773pgp.21
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:35:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w14-v6si3436948plp.31.2018.06.13.13.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:35:47 -0700 (PDT)
Subject: Re: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
 <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
 <20180613203108.k63fda4hvsqyczw7@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <355d6b1f-9188-e93b-9cf1-01ece1879cad@intel.com>
Date: Wed, 13 Jun 2018 13:35:46 -0700
MIME-Version: 1.0
In-Reply-To: <20180613203108.k63fda4hvsqyczw7@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/13/2018 01:31 PM, Kirill A. Shutemov wrote:
>> What actually happens without this patch in place?
> 
> One of processes would get the page mapped with wrong KeyID and see
> garbage. 

OK, but what about two pages with the same KeyID?  It's actually totally
possible for KSM to determine that two pages have the same plaintext and
merge them.  Why don't we do that?

> We setup mapping according to KeyID in vma->vm_page_prot.

Then why do we bother with page_keyid() and the page_ext stuff?

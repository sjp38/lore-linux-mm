Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 410176B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:36:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a23-v6so2605612pfo.23
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:36:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m21-v6si3981085pgh.664.2018.07.18.10.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 10:36:36 -0700 (PDT)
Subject: Re: [PATCHv5 02/19] mm: Do not use zero page in encrypted pages
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e09c67ab-38a7-5b76-29e6-a45627eec1e5@intel.com>
Date: Wed, 18 Jul 2018 10:36:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> Zero page is not encrypted and putting it into encrypted VMA produces
> garbage.
> 
> We can map zero page with KeyID-0 into an encrypted VMA, but this would
> be violation security boundary between encryption domains.

Why?  How is it a violation?

It only matters if they write secrets.  They can't write secrets to the
zero page.

Is this only because you accidentally inherited ->vm_page_prot on the
zero page PTE?

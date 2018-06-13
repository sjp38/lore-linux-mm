Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21F056B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:50:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o7-v6so1130929pgc.23
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:50:26 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t62-v6si2708093pgb.582.2018.06.13.10.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 10:50:25 -0700 (PDT)
Subject: Re: [PATCHv3 02/17] mm/khugepaged: Do not collapse pages in encrypted
 VMAs
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f0e4648f-a458-856e-8a06-d186c280530a@intel.com>
Date: Wed, 13 Jun 2018 10:50:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Pages for encrypted VMAs have to be allocated in a special way:
> we would need to propagate down not only desired NUMA node but also
> whether the page is encrypted.
> 
> It complicates not-so-trivial routine of huge page allocation in
> khugepaged even more. It also puts more pressure on page allocator:
> we cannot re-use pages allocated for encrypted VMA to collapse
> page in unencrypted one or vice versa.
> 
> I think for now it worth skipping encrypted VMAs. We can return
> to this topic later.

You're asking for this to be included, but without a major piece of THP
support.  Is THP support unimportant for this feature?

Are we really asking the x86 maintainers to merge this feature with this
restriction in place?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55F386B026E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:05:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so3695460pgv.12
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:05:45 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p14-v6si5240316plo.357.2018.07.19.07.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:05:44 -0700 (PDT)
Subject: Re: [PATCHv5 05/19] mm/page_alloc: Handle allocation for encrypted
 memory
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-6-kirill.shutemov@linux.intel.com>
 <95ce19cb-332c-44f5-b3a1-6cfebd870127@intel.com>
 <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b0a92a2f-cf14-c976-9fbd-fd9aa4ebcf96@intel.com>
Date: Thu, 19 Jul 2018 07:05:36 -0700
MIME-Version: 1.0
In-Reply-To: <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/19/2018 01:27 AM, Kirill A. Shutemov wrote:
>> What other code might need prep_encrypted_page()?
> 
> Custom pages allocators if these pages can end up in encrypted VMAs.
> 
> It this case compaction creates own pool of pages to be used for
> allocation during page migration.

OK, that makes sense.  It also sounds like some great information to add
near prep_encrypted_page().

Do we have any ability to catch cases like this if we get them wrong, or
will we just silently corrupt data?

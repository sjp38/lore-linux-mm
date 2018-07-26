Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 534216B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:29:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v9-v6so529517pff.4
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:29:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w6-v6si1872988pgb.61.2018.07.26.10.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:29:40 -0700 (PDT)
Subject: Re: [PATCHv5 18/19] x86/mm: Handle encrypted memory in page_to_virt()
 and __pa()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-19-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.21.1807182356520.1689@nanos.tec.linutronix.de>
 <20180723101201.wjbaktmerx3yiocd@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9966c343-1247-b505-b736-b06509e15d10@intel.com>
Date: Thu, 26 Jul 2018 10:26:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180723101201.wjbaktmerx3yiocd@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/23/2018 03:12 AM, Kirill A. Shutemov wrote:
> page_to_virt() definition overwrites default macros provided by
> <linux/mm.h>. We only overwrite the macros if MTKME is enabled
> compile-time.

Can you remind me why we need this in page_to_virt() as opposed to in
the kmap() code?  Is it because we have lots of 64-bit code that doesn't
use kmap() or something?

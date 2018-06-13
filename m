Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC6196B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:20:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x17-v6so1788295pfm.18
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:20:29 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id n7-v6si2865677pgv.641.2018.06.13.13.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:20:28 -0700 (PDT)
Subject: Re: [PATCHv3 02/17] mm/khugepaged: Do not collapse pages in encrypted
 VMAs
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-3-kirill.shutemov@linux.intel.com>
 <f0e4648f-a458-856e-8a06-d186c280530a@intel.com>
 <20180613201802.45m2745soztmkxmp@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7dccd52e-ca46-b417-5a7b-274dc7ff3e44@intel.com>
Date: Wed, 13 Jun 2018 13:20:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180613201802.45m2745soztmkxmp@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/13/2018 01:18 PM, Kirill A. Shutemov wrote:
>> Are we really asking the x86 maintainers to merge this feature with this
>> restriction in place?
> I gave it more thought after your comment and I think I see a way to get
> khugepaged work with memory encryption.

So should folks be reviewing this set, or skip it an wait on your new set?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4436B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:51:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d20-v6so1627428pfn.16
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:51:52 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v11-v6si2739738pgt.548.2018.06.13.10.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 10:51:51 -0700 (PDT)
Subject: Re: [PATCHv3 03/17] mm/ksm: Do not merge pages with different KeyIDs
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <63b7e88f-33d6-c5c1-f6cb-1bbb780e2cc4@intel.com>
Date: Wed, 13 Jun 2018 10:51:50 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Pages encrypted with different encryption keys are not subject to KSM
> merge. Otherwise it would cross security boundary.

This needs a much stronger explanation.  Which KeyID would be used for
access in the new direct mappings?  What actually happens without this
patch in place?

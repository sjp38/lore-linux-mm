Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1D276B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:58:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g20-v6so4942060pfi.2
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:58:27 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 71-v6si8067251plc.164.2018.06.15.09.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 09:58:25 -0700 (PDT)
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
 <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
 <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
 <645a4ca8-ae77-dcdd-0cbc-0da467fc210d@intel.com>
 <20180615152731.3y6rre7g66rmncxr@black.fi.intel.com>
 <cbca7e78-d70b-3eae-1c73-6ad859661b8a@intel.com>
 <20180615160613.arntdivl5gdpfwfw@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <445af5b3-eaca-0589-8899-88a3b26fb509@intel.com>
Date: Fri, 15 Jun 2018 09:58:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180615160613.arntdivl5gdpfwfw@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/15/2018 09:06 AM, Kirill A. Shutemov wrote:
> I have no idea what such concept should be called. I cannot come with
> anything better than PTE_PFN_MASK_MAX. Do you?

PTE_PRESERVE_MASK

Or maybe:

PTE_MODIFY_PRESERVE_MASK

Maybe a comment to go along with it:

/*
 * These are the bits that must be preserved during when doing a
 * PTE permission modification operation, like taking a PTE from
 * R/W->R/O.  They include the physical address and the memory
 * encryption keyID.  The paddr and the keyID never occupy the same
 * bits at the same time.  But, a given bit might be used for the keyID
 * on one system and used for the physical address on another.  As an
 * optimization, we manage them in one unit here since their combination
 * always occupies the same hardware bits.
 */

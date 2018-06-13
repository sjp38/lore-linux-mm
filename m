Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 464A56B026B
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:30:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j14-v6so1675718pfn.11
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:30:05 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p7-v6si2792761pgf.58.2018.06.13.11.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:30:04 -0700 (PDT)
Subject: Re: [PATCHv3 12/17] x86/mm: Allow to disable MKTME after enumeration
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-13-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <13ba89bb-9df3-6272-96ea-005200c3198f@intel.com>
Date: Wed, 13 Jun 2018 11:30:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-13-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Separate MKTME enumaration from enabling. We need to postpone enabling
> until initialization is complete.

	         ^ enumeration

> The new helper mktme_disable() allows to disable MKTME even if it's

s/to disable/disabling/

> enumerated successfully. MKTME initialization may fail and this
> functionallity allows system to boot regardless of the failure.

What can make it fail?

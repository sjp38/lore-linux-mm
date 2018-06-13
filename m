Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9A1C6B0010
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:20:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u16-v6so1666752pfm.15
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:20:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n12-v6si2849479pgs.560.2018.06.13.11.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:20:11 -0700 (PDT)
Subject: Re: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
Date: Wed, 13 Jun 2018 11:20:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> +int page_keyid(const struct page *page)
> +{
> +	if (mktme_status != MKTME_ENABLED)
> +		return 0;
> +
> +	return lookup_page_ext(page)->keyid;
> +}
> +EXPORT_SYMBOL(page_keyid);

Please start using a proper X86_FEATURE_* flag for this.  It will give
you all the fancy static patching that you are missing by doing it this way.

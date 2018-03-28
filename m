Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 356EB6B0279
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:59:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u23so321241pgv.7
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:59:25 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31-v6si1521100plz.467.2018.03.28.09.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:59:24 -0700 (PDT)
Subject: Re: [PATCHv2 12/14] x86/mm: Implement page_keyid() using page_ext
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-13-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b4498b2b-5092-b347-e92d-6ebd375fd947@intel.com>
Date: Wed, 28 Mar 2018 09:59:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180328165540.648-13-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/28/2018 09:55 AM, Kirill A. Shutemov wrote:
> +static inline int page_keyid(struct page *page)
> +{
> +	if (!mktme_nr_keyids)
> +		return 0;
> +
> +	return lookup_page_ext(page)->keyid;
> +}

This doesn't look very optimized.  Don't we normally try to use
X86_FEATURE_* for these checks so that we get the runtime patching *and*
compile-time optimizations?

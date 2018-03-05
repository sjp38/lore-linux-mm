Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 810676B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:00:02 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z11-v6so8466424plo.21
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:00:02 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f9si8199205pgq.743.2018.03.05.11.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:00:01 -0800 (PST)
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f9129b50-9231-abfd-9eb2-5eecad7e220d@intel.com>
Date: Mon, 5 Mar 2018 11:00:00 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> +{
> +	int i;
> +	void *v;
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		v = kmap_atomic_keyid(page, keyid + i);
> +		/* See comment in prep_encrypt_page() */
> +		clflush_cache_range(v, PAGE_SIZE);
> +		kunmap_atomic(v);
> +	}
> +}

Did you miss adding the call sites for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

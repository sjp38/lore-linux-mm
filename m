Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD8C06B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:12:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q2so7668652pgn.22
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:12:17 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y12-v6si9665141plt.453.2018.03.05.11.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:12:16 -0800 (PST)
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <eb2cc1cf-1be1-4535-f71b-fa33272a6f71@intel.com>
Date: Mon, 5 Mar 2018 11:12:15 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
>  extern void prep_encrypt_page(struct page *page, gfp_t gfp, unsigned int order);
> +extern void free_encrypt_page(struct page *page, int keyid, unsigned int order);

The grammar here is weird, I think.

Why not free_encrypted_page()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

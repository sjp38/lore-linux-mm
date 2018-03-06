Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3AFE6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:59:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c5so11611878pfn.17
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:59:06 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j134si10044016pgc.512.2018.03.06.06.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 06:59:05 -0800 (PST)
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
 <e04536bc-77e9-84d0-3c23-1dfea8542da5@intel.com>
 <20180306082743.2epdfxv4ds7hz7py@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d1faf309-837b-d385-4d0a-c840fdab8b36@intel.com>
Date: Tue, 6 Mar 2018 06:59:04 -0800
MIME-Version: 1.0
In-Reply-To: <20180306082743.2epdfxv4ds7hz7py@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2018 12:27 AM, Kirill A. Shutemov wrote:
> +	anon_vma = page_anon_vma(page);
> +	if (anon_vma_encrypted(anon_vma)) {
> +		int keyid = anon_vma_keyid(anon_vma);
> +		free_encrypt_page(page, keyid, compound_order(page));
> +	}
>  }

So, just double-checking: free_encrypt_page() neither "frees and
encrypts the page"" nor "free an encrypted page"?

That seems a bit suboptimal. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

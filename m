Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0437B6B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 12:08:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so7552576pgt.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 09:08:56 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id l128si8612028pgl.248.2018.03.05.09.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 09:08:55 -0800 (PST)
Subject: Re: [RFC, PATCH 21/22] x86/mm: Introduce page_keyid() and
 page_encrypted()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <61041640-435e-1a67-177f-a75791130514@intel.com>
Date: Mon, 5 Mar 2018 09:08:53 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> +static inline bool page_encrypted(struct page *page)
> +{
> +	/* All pages with non-zero KeyID are encrypted */
> +	return page_keyid(page) != 0;
> +}

Is this true?  I thought there was a KEYID_NO_ENCRYPT "Do not encrypt
memory when this KeyID is in use."  Is that really only limited to key 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

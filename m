Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 468F56B0027
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:17:05 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130418160920.4A00DE0085@blue.fi.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com>
 <51631206.3060605@sr71.net>
 <20130417143842.1A76CE0085@blue.fi.intel.com>
 <516F1D3C.1060804@sr71.net>
 <20130418160920.4A00DE0085@blue.fi.intel.com>
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of
 do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130418161906.2818DE0085@blue.fi.intel.com>
Date: Thu, 18 Apr 2013 19:19:06 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave@sr71.net>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Kirill A. Shutemov wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c8a8626..4669c19 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -165,6 +165,11 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
>  #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
>  #define FAULT_FLAG_TRIED	0x40	/* second try */
> +#ifdef CONFIG_CONFIG_TRANSPARENT_HUGEPAGE

Oops, s/CONFIG_CONFIG/CONFIG/.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

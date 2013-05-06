Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 4702A6B00F6
	for <linux-mm@kvack.org>; Mon,  6 May 2013 17:14:14 -0400 (EDT)
Date: Tue, 7 May 2013 01:07:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/THP: Don't use HPAGE_SHIFT in transparent hugepage
 code
Message-ID: <20130506220757.GA23468@shutemov.name>
References: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, May 07, 2013 at 02:22:32AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> For architectures like powerpc that support multiple explicit hugepage
> sizes, HPAGE_SHIFT indicate the default explicit hugepage shift. For
> THP to work the hugepage size should be same as PMD_SIZE. So use
> PMD_SHIFT directly. So move the define outside CONFIG_TRANSPARENT_HUGEPAGE
> #ifdef because we want to use these defines in generic code with
> if (pmd_trans_huge()) conditional.

Sorry, I haven't got why you move it outside #ifdef.
If CONFIG_TRANSPARENT_HUGEPAGE disabled pmd_trans_huge() will be 0 in
compile time, so BUILD_BUG() will be optimize out by GCC.

The BUILD_BUGs are useful. It's bug if you *really* use the defines with
THP disabled.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

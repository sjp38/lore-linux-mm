Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A47106B00B5
	for <linux-mm@kvack.org>; Wed, 22 May 2013 09:24:50 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id h2so2566750oag.19
        for <linux-mm@kvack.org>; Wed, 22 May 2013 06:24:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 22 May 2013 21:24:49 +0800
Message-ID: <CAJd=RBAwi6mUv0GqTobfPS7X4kpaRVD_NFg6WvCodkSmy+7uKA@mail.gmail.com>
Subject: Re: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>         page = vmf.page;
> +
> +       /*
> +        * If we asked for huge page we expect to get it or VM_FAULT_FALLBACK.
> +        * If we don't ask for huge page it must be splitted in ->fault().
> +        */
> +       BUG_ON(PageTransHuge(page) != thp);
> +
Based on the log message in 34/39(
If the area of page cache required to create huge is empty, we create a
new huge page and return it.), the above trap looks bogus.

	if (thp)
		BUG_ON(!PageTransHuge(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

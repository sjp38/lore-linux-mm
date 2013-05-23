Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6851F6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 07:57:25 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id f4so4190307oah.24
        for <linux-mm@kvack.org>; Thu, 23 May 2013 04:57:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-38-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-38-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 23 May 2013 19:57:24 +0800
Message-ID: <CAJd=RBA64hW7x6u0Mou4_z_Ox3J+sC3ZL+a4h8XcTHbXZicALg@mail.gmail.com>
Subject: Re: [PATCHv4 37/39] thp: handle write-protect exception to
 file-backed huge pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> @@ -1120,7 +1119,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>
>         page = pmd_page(orig_pmd);
>         VM_BUG_ON(!PageCompound(page) || !PageHead(page));
> -       if (page_mapcount(page) == 1) {
> +       if (PageAnon(page) && page_mapcount(page) == 1) {

Could we avoid copying huge page if
no-one else is using it, no matter anon?

>                 pmd_t entry;
>                 entry = pmd_mkyoung(orig_pmd);
>                 entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

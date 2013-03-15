Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B592B6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 02:58:59 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id v19so2912435obq.21
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 23:58:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-20-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-20-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 14:58:58 +0800
Message-ID: <CAJd=RBD2jWsMOjwXenbHu_Y3-jRm+=XR+h44Tw4KRKEb79ptqg@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 19/30] thp, mm: split huge page on mmap file page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> We are not ready to mmap file-backed tranparent huge pages.
>
It is not on todo list either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

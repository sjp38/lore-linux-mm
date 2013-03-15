Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id A413C6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 20:27:44 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id un3so2744561obb.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-4-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 08:27:43 +0800
Message-ID: <CAJd=RBAKGiCb_+yoFog6xao5bF8vqFwE9MGZ9EVbf1fe-dXnDQ@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 03/30] mm: drop actor argument of do_generic_file_read()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> There's only one caller of do_generic_file_read() and the only actor is
> file_read_actor(). No reason to have a callback parameter.
>
This cleanup is not urgent if it nukes no barrier for THP cache.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

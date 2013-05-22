Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D1B476B00A3
	for <linux-mm@kvack.org>; Wed, 22 May 2013 07:19:12 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id eh20so2120077obb.18
        for <linux-mm@kvack.org>; Wed, 22 May 2013 04:19:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-9-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-9-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 22 May 2013 19:19:11 +0800
Message-ID: <CAJd=RBCOGY6Si+uORbqtFxLCD4fs3tyGvtS_y5hQTP6Y_6CeAg@mail.gmail.com>
Subject: Re: [PATCHv4 08/39] thp: compile-time and sysfs knob for thp pagecache
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for X86_64.
>
How about THPC, TRANSPARENT_HUGEPAGE_CACHE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

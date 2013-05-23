Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8425D6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 11:49:16 -0400 (EDT)
Message-ID: <519E3A79.5070803@sr71.net>
Date: Thu, 23 May 2013 08:49:13 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 07/39] thp, mm: basic defines for transparent huge page
 cache
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-8-git-send-email-kirill.shutemov@linux.intel.com> <CAJd=RBAQzDi3RT5e6Kq3MwQPna1tRUETEjLbFka6P2QRZVWMVA@mail.gmail.com>
In-Reply-To: <CAJd=RBAQzDi3RT5e6Kq3MwQPna1tRUETEjLbFka6P2QRZVWMVA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/23/2013 03:36 AM, Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Better if one or two sentences are prepared to show that the following
> defines are necessary.
...
>> >
>> > +#define HPAGE_CACHE_ORDER      (HPAGE_SHIFT - PAGE_CACHE_SHIFT)
>> > +#define HPAGE_CACHE_NR         (1L << HPAGE_CACHE_ORDER)
>> > +#define HPAGE_CACHE_INDEX_MASK (HPAGE_CACHE_NR - 1)

Yeah, or just stick them in the patch that uses them first.  These
aren't exactly rocket science.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

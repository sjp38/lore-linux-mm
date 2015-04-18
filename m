Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 80FF66B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 18:08:06 -0400 (EDT)
Received: by widdi4 with SMTP id di4so54255194wid.0
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 15:08:06 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id o3si9111908wic.109.2015.04.18.15.08.04
        for <linux-mm@kvack.org>;
        Sat, 18 Apr 2015 15:08:05 -0700 (PDT)
Date: Sun, 19 Apr 2015 00:08:03 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150418220803.GB7972@pd.tnic>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Apr 18, 2015 at 05:59:53PM -0400, Linus Torvalds wrote:
> On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> >
> > Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
> > cause. I don't see why the commit could broke anything, but it worth
> > trying to revert and test.
> 
> Ahh, yes, that does look like a more likely culprit.

Reverted and building... will report in the next days.

Thanks guys.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

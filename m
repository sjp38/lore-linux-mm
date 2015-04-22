Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id EBC936B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:12:28 -0400 (EDT)
Received: by wgso17 with SMTP id o17so246546951wgs.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:12:28 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id he1si9007855wib.34.2015.04.22.06.12.26
        for <linux-mm@kvack.org>;
        Wed, 22 Apr 2015 06:12:27 -0700 (PDT)
Date: Wed, 22 Apr 2015 15:12:19 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150422131219.GD6897@pd.tnic>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150418220803.GB7972@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sun, Apr 19, 2015 at 12:08:03AM +0200, Borislav Petkov wrote:
> On Sat, Apr 18, 2015 at 05:59:53PM -0400, Linus Torvalds wrote:
> > On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
> > <kirill@shutemov.name> wrote:
> > >
> > > Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
> > > cause. I don't see why the commit could broke anything, but it worth
> > > trying to revert and test.
> > 
> > Ahh, yes, that does look like a more likely culprit.
> 
> Reverted and building... will report in the next days.

FWIW, box is solid with the revert and has an uptime of ~4 days so far
without hickups.

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

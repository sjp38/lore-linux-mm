Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09E046B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:59:32 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id js8so25785282lbc.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:59:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id rn9si4710557wjb.87.2016.06.16.03.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:59:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m124so10496034wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:59:30 -0700 (PDT)
Date: Thu, 16 Jun 2016 12:59:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm: rename _count, field of the struct page, to
 _refcount"
Message-ID: <20160616105928.GA12437@dhcp22.suse.cz>
References: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
 <20160616093235.GA14640@infradead.org>
 <87eg7xfmtj.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87eg7xfmtj.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

On Thu 16-06-16 12:30:16, Vitaly Kuznetsov wrote:
> Christoph Hellwig <hch@infradead.org> writes:
> 
> > On Thu, Jun 16, 2016 at 11:22:46AM +0200, Vitaly Kuznetsov wrote:
> >> _count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
> >> field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
> >> stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
> >> it is definitely possible to fix this particular tool I'm not sure about
> >> other tools which might be doing the same.
> >> 
> >> I suggest we remember the "we don't break userspace" rule and revert for
> >> 4.7 while it's not too late.
> >
> > Err, sorry - this is not "userspace".  It's crazy crap digging into
> > kernel internal structure.
> >
> > The rename was absolutely useful, so fix up your stinking pike in kdump.
> 
> Ok, sure, I'll send a patch to it. I was worried about other tools out
> there which e.g. inspect /proc/vmcore. As it is something we support
> some conservatism around it is justified.

struct page layout as some others that such a tool might depend on has
changes several times in the past so I fail to see how is it any
different this time. struct page is nothing the userspace should depend
on.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

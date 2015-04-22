Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D83866B0038
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 14:44:10 -0400 (EDT)
Received: by widdi4 with SMTP id di4so188923789wid.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:44:10 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id dk2si28120336wib.80.2015.04.22.11.44.08
        for <linux-mm@kvack.org>;
        Wed, 22 Apr 2015 11:44:09 -0700 (PDT)
Date: Wed, 22 Apr 2015 21:43:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150422184349.GB4351@node.dhcp.inet.fi>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
 <20150422131219.GD6897@pd.tnic>
 <20150422183309.GA4351@node.dhcp.inet.fi>
 <20150422184011.GK6897@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150422184011.GK6897@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, Apr 22, 2015 at 08:40:11PM +0200, Borislav Petkov wrote:
> On Wed, Apr 22, 2015 at 09:33:09PM +0300, Kirill A. Shutemov wrote:
> > Could you try patch below instead? This can give a clue what's going on.
> 
> Well, this happens on my workstation and I need it for work. I'll try to
> find another box to reproduce it on first. You could try to reproduce it
> too - it happened here while playing videos on youtube in chromium. But
> it is not easy to trigger, no particular use pattern. So I don't have a
> sure-fire way of reproducing it.

I'm running kernel with this patch on my laptop for few day without a
crash. :-/
 
> I can send you my .config if you need it.

Yes, please.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

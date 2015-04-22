Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 10C4E6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 14:40:22 -0400 (EDT)
Received: by widdi4 with SMTP id di4so67707835wid.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:40:21 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id gf1si10385352wib.52.2015.04.22.11.40.20
        for <linux-mm@kvack.org>;
        Wed, 22 Apr 2015 11:40:20 -0700 (PDT)
Date: Wed, 22 Apr 2015 20:40:11 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150422184011.GK6897@pd.tnic>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
 <20150422131219.GD6897@pd.tnic>
 <20150422183309.GA4351@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150422183309.GA4351@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, Apr 22, 2015 at 09:33:09PM +0300, Kirill A. Shutemov wrote:
> Could you try patch below instead? This can give a clue what's going on.

Well, this happens on my workstation and I need it for work. I'll try to
find another box to reproduce it on first. You could try to reproduce it
too - it happened here while playing videos on youtube in chromium. But
it is not easy to trigger, no particular use pattern. So I don't have a
sure-fire way of reproducing it.

I can send you my .config if you need it.

HTH

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

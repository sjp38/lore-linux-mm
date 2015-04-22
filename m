Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id BDCC96B006C
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 15:26:56 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so50977055ied.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:26:56 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id so2si5278708icb.67.2015.04.22.12.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 12:26:56 -0700 (PDT)
Received: by iejt8 with SMTP id t8so45390650iej.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:26:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150422183309.GA4351@node.dhcp.inet.fi>
References: <20150418205656.GA7972@pd.tnic>
	<CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
	<20150418215656.GA13928@node.dhcp.inet.fi>
	<CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
	<20150418220803.GB7972@pd.tnic>
	<20150422131219.GD6897@pd.tnic>
	<20150422183309.GA4351@node.dhcp.inet.fi>
Date: Wed, 22 Apr 2015 12:26:55 -0700
Message-ID: <CA+55aFx5NXDUsyd2qjQ+Uu3mt9Fw4HrsonzREs9V0PhHwWmGPQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, Apr 22, 2015 at 11:33 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Could you try patch below instead? This can give a clue what's going on.

Just FYI, I've done the revert in my tree.

Trying to figure out what is going on despite that is obviously a good
idea, but I'm hoping that my merge window is winding down, so I am
trying to make sure it's all "good to go"..

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

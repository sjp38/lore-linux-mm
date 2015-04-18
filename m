Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 507566B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 17:59:54 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so44917724igb.0
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 14:59:54 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id gy8si10684022icb.23.2015.04.18.14.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Apr 2015 14:59:53 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so94213538ieb.3
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 14:59:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150418215656.GA13928@node.dhcp.inet.fi>
References: <20150418205656.GA7972@pd.tnic>
	<CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
	<20150418215656.GA13928@node.dhcp.inet.fi>
Date: Sat, 18 Apr 2015 17:59:53 -0400
Message-ID: <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
> cause. I don't see why the commit could broke anything, but it worth
> trying to revert and test.

Ahh, yes, that does look like a more likely culprit.

         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

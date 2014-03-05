Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 853F46B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 12:57:37 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id z12so1699283wgg.29
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 09:57:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id oq8si1120184wjc.167.2014.03.05.09.57.34
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 09:57:35 -0800 (PST)
Date: Wed, 5 Mar 2014 12:57:25 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140305175725.GB16335@redhat.com>
References: <20140305174503.GA16335@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140305174503.GA16335@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 05, 2014 at 12:45:03PM -0500, Dave Jones wrote:
 > I just saw this on my box that's been running trinity..
 > 
 > [48825.517189] BUG: Bad rss-counter state mm:ffff880177921d40 idx:0 val:1 (Not tainted)
 > 
 > There's nothing else, no trace, nothing.  Any ideas where to begin with this?

ah, on the serial console there was also this truncated warning..

[48825.517189] BUG: Bad rss-counter state mm:ffff880177921d40 idx:0 val:1 (Not tainted)
[48924.133273] ------------[ cut here ]------------
[48924.133391] kernel BUG at include/linux/swapops.h:131!

	Dave

124 static inline struct page *migration_entry_to_page(swp_entry_t entry)
125 {
126         struct page *p = pfn_to_page(swp_offset(entry));
127         /*
128          * Any use of migration entries may only occur while the
129          * corresponding page is locked
130          */
131         BUG_ON(!PageLocked(p));
132         return p;
133 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

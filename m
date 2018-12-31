Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC5B8E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 18:02:26 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id p86-v6so8340304lja.2
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 15:02:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15-v6sor28248130ljc.33.2018.12.31.15.02.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 15:02:24 -0800 (PST)
Date: Tue, 1 Jan 2019 02:02:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
References: <20181231134223.20765-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181231134223.20765-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Dec 31, 2018 at 05:42:23AM -0800, Matthew Wilcox wrote:
> It's unnecessarily hard to find out the size of a potentially huge page.
> Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).

Good idea.

Should we add page_mask() and page_shift() too?

-- 
 Kirill A. Shutemov

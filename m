Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 451846B002E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:01:00 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31so14902456wrr.2
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:01:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f16sor8978955edj.27.2018.04.16.20.00.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 20:00:58 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:54:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/8] Various PageFlags cleanups
Message-ID: <20180416125404.v7pcjrz6ph2sah5v@node.shutemov.name>
References: <20180414043145.3953-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Fri, Apr 13, 2018 at 09:31:37PM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I was trying to understand how it was safe to test PageLocked on a tail
> page and started looking at how the pageflag policies were implemented.
> I found three actual bugs (patches 5, 7 & 8), improved the documentation
> and renamed a pile of things to be more readily explainable.

That's a great cleanup. Thanks for dealing with the mess I've created ;)

It would be nice to see overal effect on code size and *some* performance
numbers. That's rather hot code path.

-- 
 Kirill A. Shutemov

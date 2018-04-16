Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B33136B0260
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:21:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7so4159047wrg.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:21:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s4sor9612503edh.42.2018.04.16.19.21.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 19:21:07 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:46:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 6/8] mm: Turn page policies into functions
Message-ID: <20180416124606.x32qqnzttbhjmauu@node.shutemov.name>
References: <20180414043145.3953-1-willy@infradead.org>
 <20180414043145.3953-7-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414043145.3953-7-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Fri, Apr 13, 2018 at 09:31:43PM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Instead of doing quite so much macro trickery, just use functions.

Have you look on how it affects code size?
GCC sometimes way too clever.

-- 
 Kirill A. Shutemov

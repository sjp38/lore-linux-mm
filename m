Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A05036B0260
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:26:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y16so8225411wrh.22
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:26:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 93sor8893775edi.51.2018.04.16.19.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 19:26:06 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:51:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 7/8] mm: Always check PagePolicyNoCompound
Message-ID: <20180416125126.a2n5yhdamk3hvdxt@node.shutemov.name>
References: <20180414043145.3953-1-willy@infradead.org>
 <20180414043145.3953-8-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414043145.3953-8-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Fri, Apr 13, 2018 at 09:31:44PM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Currently, we're only checking that a page is not compound when we're
> setting or clearing a bit.  We should probably be checking the page
> isn't compound when testing the bit too.

Well, we can definately try this, but I'm worried about false-positives in
speculative code path.

Maybe downgrade it WARN_ONCE() or something?

-- 
 Kirill A. Shutemov

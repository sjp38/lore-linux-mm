Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161126B468A
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:38:44 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so9458091pgv.19
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:38:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l61sor3697805plb.51.2018.11.26.23.38.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:38:43 -0800 (PST)
Date: Tue, 27 Nov 2018 10:38:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/10] mm/khugepaged: collapse_shmem() remember to clear
 holes
Message-ID: <20181127073838.rmcpy7p2jzag3jc6@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261525080.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261525080.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:26:34PM -0800, Hugh Dickins wrote:
> Huge tmpfs testing reminds us that there is no __GFP_ZERO in the gfp
> flags khugepaged uses to allocate a huge page - in all common cases it
> would just be a waste of effort - so collapse_shmem() must remember to
> clear out any holes that it instantiates.
> 
> The obvious place to do so, where they are put into the page cache tree,
> is not a good choice: because interrupts are disabled there.  Leave it
> until further down, once success is assured, where the other pages are
> copied (before setting PageUptodate).
> 
> Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+

Ouch.  Thanks for catching this.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B75D6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:35:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b195so5733411wmb.1
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:35:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 93si11298119wri.328.2018.01.29.14.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 14:35:25 -0800 (PST)
Date: Mon, 29 Jan 2018 14:35:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-Id: <20180129143522.68a5332ae80d28461441a6be@linux-foundation.org>
In-Reply-To: <8ECFD324-D8A0-47DC-A6FD-B9F7D29445DC@cs.rutgers.edu>
References: <20180103082555.14592-1-mhocko@kernel.org>
	<20180103082555.14592-2-mhocko@kernel.org>
	<8ECFD324-D8A0-47DC-A6FD-B9F7D29445DC@cs.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 29 Jan 2018 17:06:14 -0500 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:

> I discover that this patch does not hold mmap_sem while migrating pages in
> do_move_pages_to_node().
> 
> A simple fix below moves mmap_sem from add_page_for_migration()
> to the outmost do_pages_move():

I'm not surprised.  Why does do_move_pages_to_node() need mmap_sem
and how is a reader to discover that fact???

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

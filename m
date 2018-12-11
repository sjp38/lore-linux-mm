Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 019718E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:39:55 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so7217300edz.15
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:39:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gv13-v6si1615985ejb.271.2018.12.11.08.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:39:53 -0800 (PST)
Date: Tue, 11 Dec 2018 17:39:52 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181211163952.GB4020@quack2.suse.cz>
References: <20181211132645.31053-1-mhocko@kernel.org>
 <20181211151542.2rjti4glj75honje@kshutemo-mobl1>
 <20181211162149.GL1286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211162149.GL1286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 11-12-18 17:21:49, Michal Hocko wrote:
> On Tue 11-12-18 18:15:42, Kirill A. Shutemov wrote:
> > For instance, DAX page fault will setup page table entry on its own and
> > return VM_FAULT_NOPAGE. It uses vmf_insert_mixed() to setup the page table
> > and ignores your pre-allocated page table.
> 
> Does this happen with a page locked and with __GFP_ACCOUNT allocation. I
> am not familiar with that code but I do not see it from a quick look.

DAX has no page to lock and also no writeback to do so the deadlock isn't
really possible when DAX is in use...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

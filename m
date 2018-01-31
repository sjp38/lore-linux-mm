Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03C366B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 02:58:52 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s22so13783209pfh.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 23:58:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 62-v6si3644577ply.651.2018.01.30.23.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jan 2018 23:58:50 -0800 (PST)
Date: Tue, 30 Jan 2018 23:58:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm/swap.c: make functions and their kernel-doc agree
Message-ID: <20180131075848.GB28275@bombadil.infradead.org>
References: <3b42ee3e-04a9-a6ca-6be4-f00752a114fe@infradead.org>
 <20180130123400.GD26445@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130123400.GD26445@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Tue, Jan 30, 2018 at 01:34:00PM +0100, Michal Hocko wrote:
> On Mon 29-01-18 16:43:55, Randy Dunlap wrote:
> > - for function pagevec_lookup_entries(), change the function parameter
> >   name from nr_pages to nr_entries since that is more descriptive of
> >   what the parameter actually is and then it matches the kernel-doc
> >   comments also
> 
> I know what is nr_pages because I do expect pages to be returned. What
> are entries? Can it be something different from pages?

entries are any page cache entries -- pages or exceptional entries.
calling this parameter nr_pages tricks you into thinking that you'll
only get pages back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

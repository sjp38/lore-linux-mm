Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 068B56B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 07:48:19 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c14so5627178wrd.2
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 04:48:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si7308500wma.38.2018.01.29.04.48.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 04:48:17 -0800 (PST)
Date: Mon, 29 Jan 2018 13:48:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180129124816.GD21609@dhcp22.suse.cz>
References: <20180116141354.GB30073@bombadil.infradead.org>
 <20180123122646.GJ1526@dhcp22.suse.cz>
 <20180129123745.GC18247@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129123745.GC18247@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Mon 29-01-18 04:37:45, Matthew Wilcox wrote:
> On Tue, Jan 23, 2018 at 01:26:46PM +0100, Michal Hocko wrote:
> > On Tue 16-01-18 06:13:54, Matthew Wilcox wrote:
> > > 3. Maybe we could rename kvfree() to just free()?  Please?  There's
> > > nothing special about it.  One fewer thing for somebody to learn when
> > > coming fresh to kernel programming.
> > 
> > I guess one has to learn about kvmalloc already and kvfree is nicely
> > symmetric to it.
> 
> I'd really like to get to:
> 
> #define malloc(sz)	kvmalloc(sz, GFP_KERNEL)
> #define free(p)		kvfree(p)
> #define realloc(p, sz)	kvrealloc(p, sz, GFP_KERNEL)	/* Doesn't exist yet */
> #define calloc(n, sz)	kvmalloc_array(n, sz, GFP_KERNEL)

Considering how many users we already have this is not really feasible.
I am also not sure we really want to mimic the userspace API. It is just
different with different consequences. You do not want to hide GFP
flags because this turned out to be just a bad idea in the past. Just
look at pte allocation functions which are unconditioanlly GFP_KERNEL
and all the pain that resulted in. We really want people to learn the
APIs and understand their limitations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

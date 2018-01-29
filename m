Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 457266B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 07:37:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m22so6510830pfg.15
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 04:37:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p17si7361851pgq.161.2018.01.29.04.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jan 2018 04:37:46 -0800 (PST)
Date: Mon, 29 Jan 2018 04:37:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180129123745.GC18247@bombadil.infradead.org>
References: <20180116141354.GB30073@bombadil.infradead.org>
 <20180123122646.GJ1526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123122646.GJ1526@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 23, 2018 at 01:26:46PM +0100, Michal Hocko wrote:
> On Tue 16-01-18 06:13:54, Matthew Wilcox wrote:
> > 3. Maybe we could rename kvfree() to just free()?  Please?  There's
> > nothing special about it.  One fewer thing for somebody to learn when
> > coming fresh to kernel programming.
> 
> I guess one has to learn about kvmalloc already and kvfree is nicely
> symmetric to it.

I'd really like to get to:

#define malloc(sz)	kvmalloc(sz, GFP_KERNEL)
#define free(p)		kvfree(p)
#define realloc(p, sz)	kvrealloc(p, sz, GFP_KERNEL)	/* Doesn't exist yet */
#define calloc(n, sz)	kvmalloc_array(n, sz, GFP_KERNEL)

... or similar.  I wouldn't be surprised if we currently spend more I$
marshalling arguments for kvmalloc than we would spend exporting a new
malloc() function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

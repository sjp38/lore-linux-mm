Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E992C6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 03:42:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so32166980wmz.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 00:42:27 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id o8si12407432wjo.159.2016.06.10.00.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 00:42:26 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so15858967wmn.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 00:42:26 -0700 (PDT)
Date: Fri, 10 Jun 2016 09:42:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mmots-2016-06-09-16-49] kernel BUG at mm/slub.c:1616
Message-ID: <20160610074223.GC32285@dhcp22.suse.cz>
References: <20160610061139.GA374@swordfish>
 <20160610063419.GB32285@dhcp22.suse.cz>
 <20160610072459.GA585@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610072459.GA585@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 10-06-16 16:24:59, Sergey Senozhatsky wrote:
> that was fast!
> 
> On (06/10/16 08:34), Michal Hocko wrote:
> [..]
> > OK, so this is flags & GFP_SLAB_BUG_MASK BUG_ON because gfp is
> > ___GFP_HIGHMEM. It is my [1] patch which has introduced it.
> > I think we need the following. Andrew could you fold it into
> > mm-memcg-use-consistent-gfp-flags-during-readahead.patch or maybe keep
> > it as a separate patch?
> > 
> > [1] http://lkml.kernel.org/r/1465301556-26431-1-git-send-email-mhocko@kernel.org
> > 
> > Thanks for the report Sergey!
> 
> after quick tests -- works for me. please see below.
[...]
> so the first bio_alloc() is ok now. what about the second bio_alloc()
> in mpage_alloc()? it'll still see the ___GFP_HIGHMEM?

Sure, early morning for me... Thanks for catching that.
---

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEDB6B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 15:24:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e14so3422396pfi.9
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 12:24:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b129si2667289pgc.387.2018.04.12.12.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Apr 2018 12:24:27 -0700 (PDT)
Date: Thu, 12 Apr 2018 12:24:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/2] Fix __GFP_ZERO vs constructor
Message-ID: <20180412192424.GB21205@bombadil.infradead.org>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180412005451.GB253442@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412005451.GB253442@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Chris Fries <cfries@google.com>, jaegeuk@kernel.org

On Thu, Apr 12, 2018 at 09:54:51AM +0900, Minchan Kim wrote:
> Matthew,
> 
> Please Cced relevant people so they know what's going on the problem
> they spent on much time. Everyone doesn't keep an eye on mailing list.

My apologies; I assumed that git send-email would pick up the people
named in the changelog.  I have now read the source code and discovered
it only picks up the people listed in Signed-off-by: and Cc:.  That
surprises me; I'll submit a patch.

> On Tue, Apr 10, 2018 at 11:03:18PM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > v1->v2:
> >  - Added review/ack tags (thanks!)
> >  - Switched the order of the patches
> >  - Reworded commit message of the patch which actually fixes the bug
> >  - Moved slab debug patches under CONFIG_DEBUG_VM to check _every_
> >    allocation and added checks in the slowpath for the allocations which
> >    end up allocating a page.
> > 
> > Matthew Wilcox (2):
> >   Fix NULL pointer in page_cache_tree_insert
> >   slab: __GFP_ZERO is incompatible with a constructor
> > 
> >  mm/filemap.c | 9 ++++-----
> >  mm/slab.c    | 7 ++++---
> >  mm/slab.h    | 7 +++++++
> >  mm/slob.c    | 4 +++-
> >  mm/slub.c    | 5 +++--
> >  5 files changed, 21 insertions(+), 11 deletions(-)
> > 
> > -- 
> > 2.16.3
> > 
> 

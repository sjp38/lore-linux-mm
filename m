Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9406B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 11:29:42 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so1384447lbi.38
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 08:29:41 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l10si3015385lbk.90.2014.09.04.08.29.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 08:29:40 -0700 (PDT)
Date: Thu, 4 Sep 2014 11:29:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: Default to node-ordering on 64-bit NUMA
 machines
Message-ID: <20140904152915.GB10794@cmpxchg.org>
References: <20140901125551.GI12424@suse.de>
 <20140902135120.GC29501@cmpxchg.org>
 <20140902152143.GL12424@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140902152143.GL12424@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linuxfoundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 02, 2014 at 04:21:43PM +0100, Mel Gorman wrote:
> On Tue, Sep 02, 2014 at 09:51:20AM -0400, Johannes Weiner wrote:
> > On Mon, Sep 01, 2014 at 01:55:51PM +0100, Mel Gorman wrote:
> > > I cannot find a good reason to incur a performance penalty on all 64-bit NUMA
> > > machines in case someone throws a brain damanged TV or graphics card in there.
> > > This patch defaults to node-ordering on 64-bit NUMA machines. I was tempted
> > > to make it default everywhere but I understand that some embedded arches may
> > > be using 32-bit NUMA where I cannot predict the consequences.
> > 
> > This patch is a step in the right direction, but I'm not too fond of
> > further fragmenting this code and where it applies, while leaving all
> > the complexity from the heuristics and the zonelist building in, just
> > on spec.  Could we at least remove the heuristics too?  If anybody is
> > affected by this, they can always override the default on the cmdline.
> 
> I see no problem with deleting the heuristics. Default node for 64-bit
> and default zone for 32-bit sound ok to you?

Is there a strong reason against defaulting both to node order?  Zone
ordering, if anything, is a niche application.  We might even be able
to remove it in the future.  We still have the backup of allowing the
user to explicitely request zone ordering on the commandline, should
someone depend on it unexpectedly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

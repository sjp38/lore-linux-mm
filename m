Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4388B6B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:07:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q22so6794024pfh.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:07:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o12-v6si2507593plg.715.2018.04.10.05.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:07:21 -0700 (PDT)
Date: Tue, 10 Apr 2018 05:07:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410120719.GC22118@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180410082243.GW21835@dhcp22.suse.cz>
 <20180410085531.m2xvzi7nenbrgbve@quack2.suse.cz>
 <20180410093241.GA21835@dhcp22.suse.cz>
 <20180410102845.3ixg2lbnumqn2o6z@quack2.suse.cz>
 <20180410111931.GA5113@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410111931.GA5113@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Fries <cfries@google.com>

On Tue, Apr 10, 2018 at 08:19:31PM +0900, Minchan Kim wrote:
> If you're okay for that, I really want to go my original patch
> Michal already gave Acked-by.

I NAK this patch.  It is completely wrong.

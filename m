Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E60036B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 18:50:26 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so22996458igb.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:50:26 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id w14si331162icl.37.2015.06.30.15.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 15:50:26 -0700 (PDT)
Received: by igblr2 with SMTP id lr2so85700700igb.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:50:26 -0700 (PDT)
Date: Tue, 30 Jun 2015 15:50:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] mm, oom: pass an oom order of -1 when triggered by
 sysrq
In-Reply-To: <20150619073202.GD4913@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506301547200.24266@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com> <alpine.DEB.2.10.1506181556180.13736@chino.kir.corp.google.com> <20150619073202.GD4913@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 19 Jun 2015, Michal Hocko wrote:

> > The force_kill member of struct oom_context isn't needed if an order of
> > -1 is used instead.
> 
> But this doesn't make much sense to me. It is not like we would _have_
> to spare few bytes here. The meaning of force_kill is clear while order
> with a weird value is a hack. It is harder to follow without any good
> reason.
> 

To me, this is the same as treating order == -1 as special in 
struct compact_control meaning that it was triggered from the command line 
and we really want to fully compact memory.  It seems to have a nice 
symmetry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

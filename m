Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 376396B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 20:11:07 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so14804359pdc.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 17:11:06 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ws2si173008pab.124.2015.06.30.17.11.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 17:11:05 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so14535293pdb.2
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 17:11:05 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:11:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [patch 1/3] mm, oom: organize oom context into struct
Message-ID: <20150701001134.GA654@swordfish>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
 <20150619001423.GA5628@swordfish>
 <alpine.DEB.2.10.1506301546270.24266@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506301546270.24266@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (06/30/15 15:46), David Rientjes wrote:
> > > There are essential elements to an oom context that are passed around to
> > > multiple functions.
> > > 
> > > Organize these elements into a new struct, struct oom_context, that
> > > specifies the context for an oom condition.
> > > 
> > 
> > s/oom_context/oom_control/ ?
> > 
> 
> I think it would be confused with the existing memory.oom_control for 
> memcg.
> 

Hello David,

Sorry, I meant that in commit message you say

:Organize these elements into a new struct, struct oom_context, that
:specifies the context for an oom condition.

but define and use `struct oom_control' (not `struct oom_context')

[..]

+       const gfp_t gfp_mask = GFP_KERNEL;
+       struct oom_control oc = {
+               .zonelist = node_zonelist(first_memory_node, gfp_mask),
+               .nodemask = NULL,
+               .gfp_mask = gfp_mask,
+               .order = 0,
+               .force_kill = true,
+       };
+

[..]

+struct oom_control {
+       struct zonelist *zonelist;
+       nodemask_t      *nodemask;
+       gfp_t           gfp_mask;
+       int             order;
+       bool            force_kill;
+};

[..]

etc.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

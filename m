Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D15992802BB
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:25:01 -0400 (EDT)
Received: by ietj16 with SMTP id j16so44006208iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:25:01 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id wf6si5340557icb.81.2015.07.15.15.25.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:25:01 -0700 (PDT)
Received: by ietj16 with SMTP id j16so44006141iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:25:01 -0700 (PDT)
Date: Wed, 15 Jul 2015 15:24:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: + mm-oom-organize-oom-context-into-struct.patch added to -mm
 tree
In-Reply-To: <20150715094138.GE5101@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507151523430.3514@chino.kir.corp.google.com>
References: <55a5931c.OSAbN+RkFn80ERhn%akpm@linux-foundation.org> <20150715094138.GE5101@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, sergey.senozhatsky.work@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed, 15 Jul 2015, Michal Hocko wrote:

> On Tue 14-07-15 15:54:20, Andrew Morton wrote:
> [...]
> > From: David Rientjes <rientjes@google.com>
> > Subject: mm, oom: organize oom context into struct
> > 
> > There are essential elements to an oom context that are passed around to
> > multiple functions.
> > 
> > Organize these elements into a new struct, struct oom_control, that
> > specifies the context for an oom condition.
> 
> Didn't you intend to name it oom_context so that it's less confusing wrt.
> oom_control usage in memcg?
>  

It's similar to struct compact_control in more ways than one, so I felt 
this naming was better.  No strong opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

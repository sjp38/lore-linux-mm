Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAC46B0255
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 17:29:59 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so44036260igb.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 14:29:59 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id x12si3833389ici.80.2015.07.01.14.29.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 14:29:58 -0700 (PDT)
Received: by igcsj18 with SMTP id sj18so145978414igc.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 14:29:58 -0700 (PDT)
Date: Wed, 1 Jul 2015 14:29:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] mm, oom: organize oom context into struct
In-Reply-To: <20150701001134.GA654@swordfish>
Message-ID: <alpine.DEB.2.10.1507011429460.14014@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com> <20150619001423.GA5628@swordfish> <alpine.DEB.2.10.1506301546270.24266@chino.kir.corp.google.com> <20150701001134.GA654@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 1 Jul 2015, Sergey Senozhatsky wrote:

> On (06/30/15 15:46), David Rientjes wrote:
> > > > There are essential elements to an oom context that are passed around to
> > > > multiple functions.
> > > > 
> > > > Organize these elements into a new struct, struct oom_context, that
> > > > specifies the context for an oom condition.
> > > > 
> > > 
> > > s/oom_context/oom_control/ ?
> > > 
> > 
> > I think it would be confused with the existing memory.oom_control for 
> > memcg.
> > 
> 
> Hello David,
> 
> Sorry, I meant that in commit message you say
> 
> :Organize these elements into a new struct, struct oom_context, that
> :specifies the context for an oom condition.
> 
> but define and use `struct oom_control' (not `struct oom_context')
> 

Oh, point very well taken, thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E6C076B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 18:47:01 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so22953051igb.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:47:01 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id d9si12562735igc.16.2015.06.30.15.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 15:47:00 -0700 (PDT)
Received: by igcur8 with SMTP id ur8so76540244igc.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:47:00 -0700 (PDT)
Date: Tue, 30 Jun 2015 15:46:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] mm, oom: organize oom context into struct
In-Reply-To: <20150619001423.GA5628@swordfish>
Message-ID: <alpine.DEB.2.10.1506301546270.24266@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com> <20150619001423.GA5628@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 19 Jun 2015, Sergey Senozhatsky wrote:

> > There are essential elements to an oom context that are passed around to
> > multiple functions.
> > 
> > Organize these elements into a new struct, struct oom_context, that
> > specifies the context for an oom condition.
> > 
> 
> s/oom_context/oom_control/ ?
> 

I think it would be confused with the existing memory.oom_control for 
memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

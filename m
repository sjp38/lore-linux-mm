Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE7B66B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:29:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b14so728376wme.17
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 01:29:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f190si2662772wma.212.2017.10.30.01.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 01:29:19 -0700 (PDT)
Date: Mon, 30 Oct 2017 09:29:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171030082916.x6xaqd4pgs2moy4y@dhcp22.suse.cz>
References: <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri 27-10-17 13:50:47, Shakeel Butt wrote:
> > Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> > else before you kill me"? It's crashing the kernel in trying to
> > protect a userspace application. How is that not insane?
> 
> In parallel to other discussion, I think we should definitely move
> from "completely oom-disabled" semantics to something similar to "kill
> me last" semantics. Is there any objection to this idea?

Could you be more specific what you mean?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

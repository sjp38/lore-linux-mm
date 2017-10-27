Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB326B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:50:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b189so3777764wmd.9
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:50:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor723066wmf.85.2017.10.27.13.50.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Oct 2017 13:50:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171025164402.GA11582@cmpxchg.org>
References: <20171024160637.GB32340@cmpxchg.org> <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org> <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org> <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com> <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org> <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 27 Oct 2017 13:50:47 -0700
Message-ID: <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

> Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> else before you kill me"? It's crashing the kernel in trying to
> protect a userspace application. How is that not insane?

In parallel to other discussion, I think we should definitely move
from "completely oom-disabled" semantics to something similar to "kill
me last" semantics. Is there any objection to this idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

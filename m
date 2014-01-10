Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f178.google.com (mail-gg0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id 533396B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:23:26 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id q2so135184ggc.23
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:23:26 -0800 (PST)
Received: from mail-yh0-x22a.google.com (mail-yh0-x22a.google.com [2607:f8b0:4002:c01::22a])
        by mx.google.com with ESMTPS id g70si9919862yhd.168.2014.01.10.13.23.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 13:23:25 -0800 (PST)
Received: by mail-yh0-f42.google.com with SMTP id z6so1520334yhz.15
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:23:25 -0800 (PST)
Date: Fri, 10 Jan 2014 13:23:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [LSF/MM ATTEND, TOPIC] memcg topics and user defined oom
 policies
In-Reply-To: <20140108151151.GA2720@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401101318160.21486@chino.kir.corp.google.com>
References: <20140108151151.GA2720@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tim Hockin <thockin@google.com>, Kamil Yurtsever <kyurtsever@google.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, 8 Jan 2014, Michal Hocko wrote:

> David was proposing memory reserves for memcg userspace OOM handlers.
> I found the idea interesting at first but I am getting more and more
> skeptical about fully supporting oom handling from within under-oom
> group usecase. Google is using this setup and we should discuss what is
> the best approach longterm because the same thing can be achieved by a
> proper memcg hierarchy as well.
> 
> While we are at memcg OOM it seems that we cannot find an easy consensus
> on when is the line when the userspace should be notified about OOM [1].
> 
> I would also like to continue discussing user defined OOM policies.
> The last attempt to resurrect the discussion [2] ended up without any
> strong conclusion but there seem to be some opposition against direct
> handling of the global OOM from userspace as being too subtle and
> dangerous. Also using memcg interface doesn't seem to be welcome warmly.
> This leaves us with either loadable modules approach or a generic filter
> mechanism which haven't been discussed that much. Or something else?
> I hope we can move forward finally.
> 

Google is interested in this topic and has been the main motivation for 
userspace oom handlers; we would like to attend for this discussion.

David Rientjes <rientjes@google.com>
Tim Hockin <thockin@google.com>, systems software, senior staff
Kamil Yurtsever <kyurtsever@google.com>, systems software

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

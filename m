Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 51D7C6B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 13:31:05 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so6435860pbc.13
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 10:31:05 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id y1si13452454pbm.64.2014.01.12.10.31.03
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 10:31:03 -0800 (PST)
Message-ID: <1389551460.7596.4.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND, TOPIC] memcg topics and user defined
 oom policies
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 12 Jan 2014 10:31:00 -0800
In-Reply-To: <alpine.DEB.2.02.1401101318160.21486@chino.kir.corp.google.com>
References: <20140108151151.GA2720@dhcp22.suse.cz>
	 <alpine.DEB.2.02.1401101318160.21486@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Tim Hockin <thockin@google.com>, Kamil Yurtsever <kyurtsever@google.com>

On Fri, 2014-01-10 at 13:23 -0800, David Rientjes wrote:
> On Wed, 8 Jan 2014, Michal Hocko wrote:
> 
> > David was proposing memory reserves for memcg userspace OOM handlers.
> > I found the idea interesting at first but I am getting more and more
> > skeptical about fully supporting oom handling from within under-oom
> > group usecase. Google is using this setup and we should discuss what is
> > the best approach longterm because the same thing can be achieved by a
> > proper memcg hierarchy as well.
> > 
> > While we are at memcg OOM it seems that we cannot find an easy consensus
> > on when is the line when the userspace should be notified about OOM [1].
> > 
> > I would also like to continue discussing user defined OOM policies.
> > The last attempt to resurrect the discussion [2] ended up without any
> > strong conclusion but there seem to be some opposition against direct
> > handling of the global OOM from userspace as being too subtle and
> > dangerous. Also using memcg interface doesn't seem to be welcome warmly.
> > This leaves us with either loadable modules approach or a generic filter
> > mechanism which haven't been discussed that much. Or something else?
> > I hope we can move forward finally.
> > 
> 
> Google is interested in this topic and has been the main motivation for 
> userspace oom handlers; we would like to attend for this discussion.
> 
> David Rientjes <rientjes@google.com>
> Tim Hockin <thockin@google.com>, systems software, senior staff
> Kamil Yurtsever <kyurtsever@google.com>, systems software

OK, so please don't do this.  Please send in Topic/attend requests as
per the CFP.  Doing this gives us no way to judge the merits of the
request and, administratively, it gets lost because the way I populate
the attendance request table is to filter on the topic/attend requests
and then fold the threads up to the head.

Please send in one separate topic/attend email authored by the person
who wants to attend.

Thanks,

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

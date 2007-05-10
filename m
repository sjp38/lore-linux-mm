Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l4AJUxCd003930
	for <linux-mm@kvack.org>; Thu, 10 May 2007 12:30:59 -0700
Received: from an-out-0708.google.com (ancc23.prod.google.com [10.100.29.23])
	by zps78.corp.google.com with ESMTP id l4AJUnua017162
	for <linux-mm@kvack.org>; Thu, 10 May 2007 12:30:49 -0700
Received: by an-out-0708.google.com with SMTP id c23so261325anc
        for <linux-mm@kvack.org>; Thu, 10 May 2007 12:30:49 -0700 (PDT)
Message-ID: <b040c32a0705101230n7cd557eaw8dbd00f7a2f8a58@mail.gmail.com>
Date: Thu, 10 May 2007 12:30:48 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <Pine.LNX.4.64.0705101141160.10271@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
	 <20070509164859.15dd347b.pj@sgi.com>
	 <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
	 <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
	 <b040c32a0705101132m5baacb9cx59f15fe9dccfff05@mail.gmail.com>
	 <Pine.LNX.4.64.0705101141160.10271@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/10/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Thu, 10 May 2007, Ken Chen wrote:
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index da94639..c2aec0e 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -884,6 +884,10 @@ asmlinkage long sys_mbind(unsigned long
> >        err = get_nodes(&nodes, nmask, maxnode);
> >        if (err)
> >                return err;
> > +#ifdef CONFIG_CPUSETS
> > +       /* Restrict the nodes to the allowed nodes in the cpuset */
> > +       nodes_and(nodes, nodes, current->mems_allowed);
> > +#endif
> >        return do_mbind(start, len, mode, &nodes, flags);
>
> Did I screw up whitespace there?

No, the patch was fine.  I copy'n paste from xterm which turns all tab
into space.  It's crappy xterm stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

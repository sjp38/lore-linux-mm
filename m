Date: Tue, 12 Feb 2008 10:56:56 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to allowed nodes V3
In-Reply-To: <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>
References: <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>
Message-Id: <20080212103944.29A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> > # remove almost CC'd
> 
> Please don't remove cc's that were included on the original posting if 
> you're passing the patch along.

Oops, sorry.
I was not worth of solicitude. 


> > OK.
> > I append my Tested-by.(but not Singed-off-by because my work is very little).
> > 
> > and, I attached .24 adjusted patch.
> > my change is only line number change and remove extra space.
> 
> Andrew may clarify this, but I believe you need to include a sign-off line 
> even if you alter just that one whitespace.
> 
>  [ I edited that whitespace in my own copy of this patch when I applied it 
>    to my tree because git complained about it (and my patchset removes the 
>    same line with the whitespace removed). ]

Hmm..
OK


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> > I'm still deferring David Rientjes' suggestion to fold
> > mpol_check_policy() into mpol_new().  We need to sort out whether
> > mempolicies specified for tmpfs and hugetlbfs mounts always need the
> > same "contextualization" as user/application installed policies.  I
> > don't want to hold up this bug fix for that discussion.  This is
> > something Paul J will need to address with his cpuset/mempolicy rework,
> > so we can sort it out in that context.
> > 
> 
> I took care of this in my patchset from this morning, so I think we can 
> drop this disclaimer now.

Disagreed.

this patch is regression fixed patch.
regression should fixed ASAP.

your patch is very nice patch.
but it is feature enhancement.
the feature enhancement should tested by many people in -mm tree for a while.

end up, timing of mainline merge is large different.


> > 2) In existing mpol_check_policy() logic, after "contextualization":
> >    a) MPOL_DEFAULT:  require that in coming mask "was_empty"
> 
> While my patchset effectively obsoletes this patch (but is nonetheless 
> based on top of it), I don't understand why you require that MPOL_DEFAULT 
> nodemasks are empty.
> 
> mpol_new() will not dynamically allocate a new mempolicy in that case 
> anyway since it is the system default so the only reason why 
> set_mempolicy(MPOL_DEFAULT, numa_no_nodes, ...) won't work is because of 
> this addition to mpol_check_policy().
> 
> In other words, what is the influence to dismiss a MPOL_DEFAULT mempolicy 
> request from a user as invalid simply because it includes set nodes in the 
> nodemask?

Hmm..
By which version are you testing?


my testing result was

                       set_mempolicy(MPOL_DEFAULT,NULL)  set_mempolicy(MPOL_DEFAULT,numa_no_nodes)
                      ------------------------------------------------------------------------------
2.6.24                      success                                   success
2.6.24 + lee-patch          success                                   success



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

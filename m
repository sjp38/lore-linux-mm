Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE9A6B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 08:31:28 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id k48so654493wev.17
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:31:26 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id wx3si6977204wjc.170.2014.09.12.05.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 05:31:25 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id e4so534507wiv.9
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:31:25 -0700 (PDT)
Date: Fri, 12 Sep 2014 14:31:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140912123122.GF12156@dhcp22.suse.cz>
References: <20140911213338.GA4098@localhost.localdomain>
 <20140912080853.GA12156@dhcp22.suse.cz>
 <20140912082329.GA12330@localhost.localdomain>
 <20140912121817.GE12156@dhcp22.suse.cz>
 <20140912122143.GA20622@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140912122143.GA20622@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niv Yehezkel <executerx@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, oleg@redhat.com

On Fri 12-09-14 08:21:43, Niv Yehezkel wrote:
> On Fri, Sep 12, 2014 at 02:18:17PM +0200, Michal Hocko wrote:
> > On Fri 12-09-14 04:23:29, Niv Yehezkel wrote:
> > [...]
> > > From 1e92f232e9367565d93629b54117b27b9bbfebda Mon Sep 17 00:00:00 2001
> > > From: Niv Yehezkel <executerx@gmail.com>
> > > Date: Fri, 12 Sep 2014 04:21:48 -0400
> > > Subject: [PATCH] break after selecting process to kill
> > > 
> > > 
> > 
> > Now the justification please ;)
> > 
> > > Signed-off-by: Niv Yehezkel <executerx@gmail.com>
> > > ---
> > >  mm/oom_kill.c |    4 +++-
> > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 1e11df8..3203578 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -315,7 +315,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  		case OOM_SCAN_SELECT:
> > >  			chosen = p;
> > >  			chosen_points = ULONG_MAX;
> > > -			/* fall through */
> > > +			break;
> > >  		case OOM_SCAN_CONTINUE:
> > >  			continue;
> > >  		case OOM_SCAN_ABORT:
> > > @@ -324,6 +324,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  		case OOM_SCAN_OK:
> > >  			break;
> > >  		};
> > > +		if (chosen_points == ULONG_MAX)
> > > +			break;
> > >  		points = oom_badness(p, NULL, nodemask, totalpages);
> > >  		if (!points || points < chosen_points)
> > >  			continue;
> > > -- 
> > > 1.7.10.4
> > > 
> > 
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> As mentioned earlier, there's no need to keep iterating over all
> running processes once the process with the highest score has been found.

Please refer to Documentation/SubmittingPatches, especially "2) Describe
your changes." section for more information about the preferred
workflow. I really do not want to be nit picking on you but this is not
the right way to send your changes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

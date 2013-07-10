Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 1E2346B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 02:57:52 -0400 (EDT)
Date: Wed, 10 Jul 2013 08:57:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: Honor min_free_kbytes set by user
Message-ID: <20130710065749.GA4437@dhcp22.suse.cz>
References: <1372954036-16988-1-git-send-email-mhocko@suse.cz>
 <1372954239.1886.40.camel@joe-AO722>
 <20130704161641.GD7833@dhcp22.suse.cz>
 <20130704162005.GE7833@dhcp22.suse.cz>
 <alpine.LRH.2.00.1307100139220.4045@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1307100139220.4045@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-07-13 01:40:06, Jiri Kosina wrote:
> On Thu, 4 Jul 2013, Michal Hocko wrote:
[...]
> > >From 5f089c0b2a57ff6c08710ac9698d65aede06079f Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 4 Jul 2013 17:15:54 +0200
> > Subject: [PATCH] mm: Honor min_free_kbytes set by user
> > 
> > min_free_kbytes is updated during memory hotplug (by init_per_zone_wmark_min)
> > currently which is right thing to do in most cases but this could be
> > unexpected if admin increased the value to prevent from allocation
> > failures and the new min_free_kbytes would be decreased as a result of
> > memory hotadd.
> > 
> > This patch saves the user defined value and allows updating
> > min_free_kbytes only if it is higher than the saved one.
> > 
> > A warning is printed when the new value is ignored.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/page_alloc.c | 24 +++++++++++++++++-------
> >  1 file changed, 17 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 22c528e..9c011fc 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -204,6 +204,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
> >  };
> >  
> >  int min_free_kbytes = 1024;
> > +int user_min_free_kbytes;
> 
> Minor nit: any reason this can't be static?

Yes, it can and should be static. Care to queue a fix in your trivial
tree? I can post a fix if you want.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

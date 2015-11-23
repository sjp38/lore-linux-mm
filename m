Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 28F616B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 06:50:38 -0500 (EST)
Received: by qgeb1 with SMTP id b1so111929606qge.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:50:37 -0800 (PST)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id 111si10859700qgx.29.2015.11.23.03.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 03:50:36 -0800 (PST)
Received: by qgeb1 with SMTP id b1so111929274qge.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:50:36 -0800 (PST)
Date: Mon, 23 Nov 2015 06:50:33 -0500
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] mm: fix up sparse warning in gfpflags_allow_blocking
Message-ID: <20151123065033.0a8bdc00@tlielax.poochiereds.net>
In-Reply-To: <20151123095048.GB21436@dhcp22.suse.cz>
References: <1448030459-20990-1-git-send-email-jeff.layton@primarydata.com>
	<20151123095048.GB21436@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Nov 2015 10:50:49 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 20-11-15 09:40:59, Jeff Layton wrote:
> > sparse says:
> > 
> >     include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
> >     include/linux/gfp.h:274:26:    expected bool
> >     include/linux/gfp.h:274:26:    got restricted gfp_t
> > 
> > ...add a forced cast to silence the warning.
> > 
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  include/linux/gfp.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 6523109e136d..8942af0813e3 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
> >  
> >  static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> >  {
> > -	return gfp_flags & __GFP_DIRECT_RECLAIM;
> > +	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
> 
> Wouldn't (gfp_flags & __GFP_DIRECT_RECLAIM) != 0 be easier/better to read?
> 

Yeah, good point. Andrew, do you want me to respin that?

-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

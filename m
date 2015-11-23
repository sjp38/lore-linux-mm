Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 736146B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:46:05 -0500 (EST)
Received: by qkda6 with SMTP id a6so63380658qkd.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:46:05 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id 190si8501400qhh.130.2015.11.23.12.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:46:04 -0800 (PST)
Received: by qgea14 with SMTP id a14so122243663qge.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:46:04 -0800 (PST)
Date: Mon, 23 Nov 2015 15:46:00 -0500
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH v2] mm: fix up sparse warning in gfpflags_allow_blocking
Message-ID: <20151123154600.128dd818@tlielax.poochiereds.net>
In-Reply-To: <20151123124503.GJ21050@dhcp22.suse.cz>
References: <1448281409-13132-1-git-send-email-jeff.layton@primarydata.com>
	<20151123124503.GJ21050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Nov 2015 13:45:04 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 23-11-15 07:23:29, Jeff Layton wrote:
> > sparse says:
> > 
> >     include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
> >     include/linux/gfp.h:274:26:    expected bool
> >     include/linux/gfp.h:274:26:    got restricted gfp_t
> > 
> > Add a comparison to zero to have it return bool.
> > 
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> 

Doh! The original version has already been merged. I'll spin up a new
patch that will apply to mainline when I get a bit of time.

Thanks,
Jeff

> > ---
> >  include/linux/gfp.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > [v2: use a compare instead of forced cast, as suggested by Michal]
> > 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 6523109e136d..b76c92073b1b 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
> >  
> >  static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> >  {
> > -	return gfp_flags & __GFP_DIRECT_RECLAIM;
> > +	return (gfp_flags & __GFP_DIRECT_RECLAIM) != 0;
> >  }
> >  
> >  #ifdef CONFIG_HIGHMEM
> > -- 
> > 2.4.3
> 


-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

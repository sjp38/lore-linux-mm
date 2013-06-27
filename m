Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BE6246B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 14:05:53 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr13so1237902pbb.34
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:05:53 -0700 (PDT)
Date: Thu, 27 Jun 2013 11:05:50 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130627180550.GA2276@teo>
References: <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz>
 <20130627153528.GA5006@gmail.com>
 <20130627161103.GA25165@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130627161103.GA25165@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Thu, Jun 27, 2013 at 06:11:03PM +0200, Michal Hocko wrote:
> > If we send critical but there isn't big memory pressure, maybe
> > critical handler would kill some process and the result is that
> > killing another process unnecessary. That's really thing we should
> > avoid.

Yes, so that is why I actually want to ack the patch... It might be not an
ideal solution, but to me it seems like a good for the time being.

(Actually I should have done that check myself.)

> > > The THP case made sense because nr_scanned is in LRU elements units
> > > while nr_reclaimed is in page units which are different so nr_reclaim
> > > might be higher than nr_scanned (so nr_taken would be more approapriate
> > > for vmpressure).
> > 
> > In case of THP, 512 page is equal to vmpressure_win so if we change
> > nr_scanned with nr_taken, it could easily make vmpressure notifier
> 
> Wasn't 512 selected for vmpressure_win exactly for this reason?

Nope. The current vmpressure_win was selected kind of arbitrary, i.e. it
worked good for most of my test cases.

> Shouldn't we rather fix that assumption?

If there is any assumption (which I had not in my mind :), then we
definitely should do that, since vmpressure_win is going to be
machine-size dependant.

Thanks,

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

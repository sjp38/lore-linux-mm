Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D59826B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 08:17:56 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:17:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130628121751.GA5125@dhcp22.suse.cz>
References: <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz>
 <20130627153528.GA5006@gmail.com>
 <20130627161103.GA25165@dhcp22.suse.cz>
 <20130627180550.GA2276@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627180550.GA2276@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Minchan Kim <minchan@kernel.org>, Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Thu 27-06-13 11:05:50, Anton Vorontsov wrote:
> On Thu, Jun 27, 2013 at 06:11:03PM +0200, Michal Hocko wrote:
> > > If we send critical but there isn't big memory pressure, maybe
> > > critical handler would kill some process and the result is that
> > > killing another process unnecessary. That's really thing we should
> > > avoid.
> 
> Yes, so that is why I actually want to ack the patch... It might be not an
> ideal solution, but to me it seems like a good for the time being.

I am still not sure why a) nr_taken shouldn't be used instead of
nr_scanned b) why there should be any signal if the current allocator
dies and the direct reclaim is terminated prematurely.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

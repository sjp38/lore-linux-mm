Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 7AEE56B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 08:26:09 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:26:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130628122607.GC5125@dhcp22.suse.cz>
References: <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz>
 <20130627153528.GA5006@gmail.com>
 <20130627161103.GA25165@dhcp22.suse.cz>
 <20130627235435.GA15637@bbox>
 <010801ce73d3$227f8800$677e9800$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010801ce73d3$227f8800$677e9800$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Fri 28-06-13 16:43:09, Hyunhee Kim wrote:
> When this happens, we cannot tell anything about the current pressure
> level.

So we tell a random one? No, this doesn't make any sense to me. THP
should be fixed (use nr_taken) and signal_pending should be treated at
the vmpressure level and I think no signal should be sent in that case
as "we cannot say what is the current level"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

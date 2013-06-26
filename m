Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 227886B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 03:39:12 -0400 (EDT)
Date: Wed, 26 Jun 2013 16:39:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] memcg: add interface to specify thresholds of vmpressure
Message-ID: <20130626073917.GE29127@bbox>
References: <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <005801ce6f1a$f1664f90$d432eeb0$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <005801ce6f1a$f1664f90$d432eeb0$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Sat, Jun 22, 2013 at 04:34:34PM +0900, Hyunhee Kim wrote:
> Memory pressure is calculated based on scanned/reclaimed ratio. The higher
> the value, the more number unsuccessful reclaims there were. These thresholds
> can be specified when each event is registered by writing it next to the
> string of level. Default value is 60 for "medium" and 95 for "critical"
> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

As I mentioned eariler thread, it's not a good idea to expose each level's
raw value to user space. If it's a problem, please fix default vaule and
send a patch with number to convince us although I'm not sure we can get
a stable number.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

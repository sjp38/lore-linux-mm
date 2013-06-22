Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0F7E66B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 20:27:52 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so8580658pad.30
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 17:27:52 -0700 (PDT)
Date: Fri, 21 Jun 2013 17:27:44 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
Message-ID: <20130622002744.GA29172@lizard.mcd26095.sjc.wayport.net>
References: <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <20130621164413.GA4759@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130621164413.GA4759@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Sat, Jun 22, 2013 at 01:44:14AM +0900, Minchan Kim wrote:
[...]
> 3. The reclaimed could be greater than scanned in vmpressure_evnet
>    by several reasons. Totally, It could trigger wrong event.

Yup, and in that case the best we can do is just ignore the event (i.e.
not pass it to the userland): thing is, based on the fact that
'reclaimed > scanned' we can't actually conclude anything about the
pressure: it might be still high, or we actually freed enough.

Thanks,

Anton

p.s. I was somewhat sure that someone sent a patch to ignore 'reclaimed >
scanned' situation, but I cannot find it in my mailbox. Maybe I was
dreaming about it? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 364976B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 03:50:33 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id j6so5000137oag.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 00:50:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130626073917.GE29127@bbox>
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
	<20130626073917.GE29127@bbox>
Date: Wed, 26 Jun 2013 16:50:32 +0900
Message-ID: <CAH9JG2WXMVQPgB7RFW_NLjOwMRaMdoNfjauWdv7KeYsHWkb7eQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: add interface to specify thresholds of vmpressure
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name

On Wed, Jun 26, 2013 at 4:39 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Sat, Jun 22, 2013 at 04:34:34PM +0900, Hyunhee Kim wrote:
>> Memory pressure is calculated based on scanned/reclaimed ratio. The higher
>> the value, the more number unsuccessful reclaims there were. These thresholds
>> can be specified when each event is registered by writing it next to the
>> string of level. Default value is 60 for "medium" and 95 for "critical"
>>
>> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
>> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>
> As I mentioned eariler thread, it's not a good idea to expose each level's
> raw value to user space. If it's a problem, please fix default vaule and
> send a patch with number to convince us although I'm not sure we can get
> a stable number.
that's reason to send this patch, can we make a reasonable value to
cover all cases?
which number are satified for all person. I really wonder it.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

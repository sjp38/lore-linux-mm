Received: by wr-out-0506.google.com with SMTP id 60so3483552wri.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2008 17:21:45 -0800 (PST)
Message-ID: <44c63dc40802261721j5889e963j7924052a439d1de0@mail.gmail.com>
Date: Wed, 27 Feb 2008 10:21:42 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [7/7] per cpu fast lookup
In-Reply-To: <20080227100953.980ba34d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080225121849.191ac900.kamezawa.hiroyu@jp.fujitsu.com>
	 <44c63dc40802260526x3283baf2tb4ab71b384a4ab58@mail.gmail.com>
	 <20080227083714.fbe34483.kamezawa.hiroyu@jp.fujitsu.com>
	 <44c63dc40802261657m2930f166mb6eb2378ee843988@mail.gmail.com>
	 <20080227100953.980ba34d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>  > >  > why do you prevent when it happen in interrupt context ?
>  > >  > Do you have any reason ?
>  > >  >
>  > >  looking up isn't done under irq disable but under preempt disable.
>  >
>  > I can't understand your point.
>  > Is that check is really necessary if save_result function use
>  > get_cpu_var and put_cpu_var in save_result ?
>  >
>  looku up is done by this routine.
>  ==
>
> +       if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
>  +               ret = pcp->ents[hnum].base + (pfn - (idx << PCGRP_SHIFT));
>  ==
>  Then,
>
>   check pcp->ents[hnum].idx == idx, match.
>   <interrupt>
>               ---------------------------> some codes.
>                                            get_page_cgroup()
>                                                cache_miss--> __get_page_cgroup()
>                                                               --> save_result()
>                                            .............
>   <ret_from_IRQ> <--------------------------
>
>  What will I see ?

I see. Thanks for your good explanation.  :-)
I hope you insert above explanation with comment.

>  Thanks,
>  -Kame
>
-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 008846B006C
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:36:38 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1TB4AJ-0000I7-SU
	for linux-mm@kvack.org; Mon, 10 Sep 2012 15:36:39 +0200
Received: from 112.132.200.126 ([112.132.200.126])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 15:36:39 +0200
Received: from xiyou.wangcong by 112.132.200.126 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 15:36:39 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with
 swappiness==0
Date: Mon, 10 Sep 2012 13:36:25 +0000 (UTC)
Message-ID: <k2kqcp$a12$1@ger.gmane.org>
References: <5038E7AA.5030107@gmail.com>
 <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
 <504CCECF.9020104@redhat.com>
 <CAGDaZ_pLTR3FZy4-txF7ZhMy60xp_BB=-JORd8OhcGcJOG6YCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: stable@vger.kernel.org

On Sun, 09 Sep 2012 at 18:03 GMT, Shentino <shentino@gmail.com> wrote:
>
> Just curious, but what theoretically would happen if someone were to
> want to set swappiness to 200 or something?
>
> Should it be sorta like vfs_cache_pressure?
>


How could it be set to 200? As 0~100 is valid:

        {
	                .procname       = "swappiness",
		        .data           = &vm_swappiness,
		        .maxlen         = sizeof(vm_swappiness),
			.mode           = 0644,
		        .proc_handler   = proc_dointvec_minmax,
			.extra1         = &zero,
			.extra2         = &one_hundred,
        },

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

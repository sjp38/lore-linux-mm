Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3250B280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:07:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i123so1528927pgd.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:07:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si839018pgv.239.2017.11.16.05.07.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 05:07:50 -0800 (PST)
Date: Thu, 16 Nov 2017 14:07:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20171116130746.i642wszwvyb7q6hm@dhcp22.suse.cz>
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
 <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
 <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On Thu 16-11-17 21:48:05, Byungchul Park wrote:
> On 11/16/2017 9:02 PM, Michal Hocko wrote:
> > for each struct page. So you are doubling the size. Who is going to
> > enable this config option? You are moving this to page_ext in a later
> > patch which is a good step but it doesn't go far enough because this
> > still consumes those resources. Is there any problem to make this
> > kernel command line controllable? Something we do for page_owner for
> > example?
> 
> Sure. I will add it.
> 
> > Also it would be really great if you could give us some measures about
> > the runtime overhead. I do not expect it to be very large but this is
> 
> The major overhead would come from the amount of additional memory
> consumption for 'lockdep_map's.

yes

> Do you want me to measure the overhead by the additional memory
> consumption?
> 
> Or do you expect another overhead?

I would be also interested how much impact this has on performance. I do
not expect it would be too large but having some numbers for cache cold
parallel kbuild or other heavy page lock workloads.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D502A6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:36:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so7585596wmi.11
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:36:04 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 199si20680516wml.90.2017.07.04.05.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:36:03 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:35:59 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 1/2] mm: swap: Provide
 lru_add_drain_all_cpuslocked()
In-Reply-To: <b2522a26-334b-c66e-4cca-c9eeb4aa6f93@suse.cz>
Message-ID: <alpine.DEB.2.20.1707041434380.9000@nanos>
References: <20170704093232.995040438@linutronix.de> <20170704093421.419329357@linutronix.de> <b2522a26-334b-c66e-4cca-c9eeb4aa6f93@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 4 Jul 2017, Vlastimil Babka wrote:
> >  
> > -void lru_add_drain_all(void)
> > +void lru_add_drain_all_cpuslocked(void)
> >  {
> >  	static DEFINE_MUTEX(lock);
> >  	static struct cpumask has_work;
> > @@ -701,7 +701,6 @@ void lru_add_drain_all(void)
> >  		return;
> >  
> >  	mutex_lock(&lock);
> > -	get_online_cpus();
> 
> Is there a an assertion check that we are locked, that could be put in
> e.g. VM_WARN_ON_ONCE()?

There is a lockdep assertion lockdep_assert_cpus_held() which could be
used. Forgot to add it.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A03FC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E57F20857
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:39:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AruFYuA6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E57F20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6C8E8E0002; Tue, 29 Jan 2019 12:39:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1BFB8E0001; Tue, 29 Jan 2019 12:39:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7568E0002; Tue, 29 Jan 2019 12:39:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 420C58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:39:49 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id f22-v6so5961085lja.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:39:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KIaWr0Zq9+BtRkxw1MjIPRqsGQx0NbC1v2Rp0V9/A/c=;
        b=FEvPWPHkVub2K8tvLbquimcdMCJLzp+eGwd8fe61XvEMvNPk0WS3RAidTx6cQf+aGq
         5QJjiV+CR36tv0R1jQ51Ytb7dW2Fgrp1I8Np/oab7HUF/UnFzEpNFepcBTABIPpn2N0Y
         Rxjid/CXqFH7S6aFCUbarfRD+GrLZ6fwt4gOpH9+ENyQNEdcZesxpKsDKwcCaaN/JTHK
         ruCZ2FOItHps8dRc+c4Js43oJbtXaYbOfXguey4gPVk4TAX6QdF1Bs6PEmKwqgDJ46TK
         MFV1Xwxfng6FNRgjf1JsH9nfcU22qqFubRiWKWLYor2kwHCEYn4lYjvQD1cwXVgk1DhA
         fmUw==
X-Gm-Message-State: AJcUukdEyKm5UMlAj2f88QdN38yEKJaNjaGcGd64ZUnr5+oHFqc57BQx
	4qheo0J8toSuv2/DuV55wrI+9BJ9pKqPn1d+1sfaxzUvup2E8BmL1DX4oC7DvYsuFnuccFnEx1h
	VVSyUE0waCU2/jtnOcnl6rV4htkmCWgLQQeUiyBfLz4HLhuXPxkCmGyS8VZ8VEho0sSRS814ggr
	EBT2vr+U9UpYxmuXfVrCvZbroAgegIDHh7YxPxudAlTdwwNq/DQEdG094Es1Lfw17NPGaeH4at5
	DFZhngTSV+UcfeiocLkmfTWab5kfO3MIL+igBo2ELuAf9ccTvYuTJI9J68EYGGq5Trx01b0ncz5
	6lcfqWQvM70HNHnRYuli4fKXSgIDZPY8QbL3wZt68KLwBD7cRS1Loeqy/D63m/gfo/gkYQ8+mff
	L
X-Received: by 2002:a2e:568d:: with SMTP id k13-v6mr23122198lje.105.1548783588500;
        Tue, 29 Jan 2019 09:39:48 -0800 (PST)
X-Received: by 2002:a2e:568d:: with SMTP id k13-v6mr23122144lje.105.1548783587348;
        Tue, 29 Jan 2019 09:39:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548783587; cv=none;
        d=google.com; s=arc-20160816;
        b=rCN9DKM3nSpcQlu+VHuhrS/O6t9NhHzvGPQIBPzTURj8tMEuOUhLTjAcd2xMNgKJFi
         xMW7smB2mWIC+oKPw8w0KpbQRGg1y1jn5Pmib0FIcwnUchu1ozvWn30Eglm848yPx/lD
         jTl9rdDxGOYaVaEp5+sHzZ/VxYpMVGMOqylI60g/9BYn4SzeofLQKIdlDbHQy5ApoG/f
         HSpjGeirUc1CW5GYctTPL7b4Ggy3QuQ9H0LEhah9u3mVF6tdrHUC+76/iR2JWQI5lAIw
         ncASaXWjfG589s8OxUgAqJGnWLue9q/rYwsaJ+I2pcEmyCb3a7rFIvirQxGFzj9efia9
         CMog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=KIaWr0Zq9+BtRkxw1MjIPRqsGQx0NbC1v2Rp0V9/A/c=;
        b=hSaAABpWIKJ1P1NvojPf/JpajdPV8vmbi39JeQYUFIaOpvAznmg4ngfjDaWgnXIcH9
         B+6zrRPHqSDTzTzBf5jkO9IRf7sqtc0o3a4/Qo+do/rKir+JFCKn70UfdVoG7fVF/OT4
         oOjDW6rz2RWGhkXNpxs3s8ErFuZ/IorPFwDtf/zUKW48cL0IsuEkprF6Llyx534bs+c8
         hF+xmQVbnsBXLyvk+2rk9lqmJWN4CVJWeqQ+RxTr9xOZYS6h/kM6lYNHNskiQQcuZq1C
         gNjQkCthFAK/DkP++M8dvFUPK2uaWysB5jNzUwItUa2qxbVgLaSg3qFWIcejOIsxvwpQ
         EkKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AruFYuA6;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22-v6sor13166778lji.38.2019.01.29.09.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 09:39:47 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AruFYuA6;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KIaWr0Zq9+BtRkxw1MjIPRqsGQx0NbC1v2Rp0V9/A/c=;
        b=AruFYuA615iqmLt6moyy7Tr8BAEm5qxgDyZzBrSBg6C2Jh3ZJE2PgHzTmAQZhRXkZQ
         fqBrdqqReYLN40c6roqStJJcfijWgr1eXjJC0+9x7IvCgpPCvYynxOemgUspEWGjsLFf
         w5tyLM/4WD3zFo+xuKTbOb8P9OWPmIpHFUehuicWryw6KwRm6xlbhTx3pDTAL5GKLzO+
         yC5AEqAnlROh0B3rH+GDChw5a+5tJc7gVdgu8odLXPzVdG3NTRdqemNu385kw5npus0S
         OpwwN0RBjuI3O0apN66HWAJg8zRhKiaLQZUBIzP1XjYXx/FU39AgOt0q4SNCPwiZ24jd
         IBww==
X-Google-Smtp-Source: ALg8bN7W6EIoEIQoFEsV3JNk/AtCA2tr4O0YD6DSYh1j8+wPjM/kByazFbNqyIb8ydT1zvuH61jN1w==
X-Received: by 2002:a2e:3a04:: with SMTP id h4-v6mr23245958lja.81.1548783586715;
        Tue, 29 Jan 2019 09:39:46 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id l17sm3553290lfk.40.2019.01.29.09.39.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 09:39:45 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 29 Jan 2019 18:39:36 +0100
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-ID: <20190129173936.4sscooiybzbhos77@pc636>
References: <20190124115648.9433-1-urezki@gmail.com>
 <20190124115648.9433-3-urezki@gmail.com>
 <20190128224528.GB38107@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128224528.GB38107@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 05:45:28PM -0500, Joel Fernandes wrote:
> On Thu, Jan 24, 2019 at 12:56:48PM +0100, Uladzislau Rezki (Sony) wrote:
> > commit 763b218ddfaf ("mm: add preempt points into
> > __purge_vmap_area_lazy()")
> > 
> > introduced some preempt points, one of those is making an
> > allocation more prioritized over lazy free of vmap areas.
> > 
> > Prioritizing an allocation over freeing does not work well
> > all the time, i.e. it should be rather a compromise.
> > 
> > 1) Number of lazy pages directly influence on busy list length
> > thus on operations like: allocation, lookup, unmap, remove, etc.
> > 
> > 2) Under heavy stress of vmalloc subsystem i run into a situation
> > when memory usage gets increased hitting out_of_memory -> panic
> > state due to completely blocking of logic that frees vmap areas
> > in the __purge_vmap_area_lazy() function.
> > 
> > Establish a threshold passing which the freeing is prioritized
> > back over allocation creating a balance between each other.
> 
> I'm a bit concerned that this will introduce the latency back if vmap_lazy_nr
> is greater than half of lazy_max_pages(). Which IIUC will be more likely if
> the number of CPUs is large.
> 
The threshold that we establish is two times more than lazy_max_pages(),
i.e. in case of 4 system CPUs lazy_max_pages() is 24576, therefore the
threshold is 49152, if PAGE_SIZE is 4096.

It means that we allow rescheduling if vmap_lazy_nr < 49152. If vmap_lazy_nr 
is higher then we forbid rescheduling and free areas until it becomes lower
again to stabilize the system. By doing that, we will not allow vmap_lazy_nr
to be enormously increased.

>
> In fact, when vmap_lazy_nr is high, that's when the latency will be the worst
> so one could say that that's when you *should* reschedule since the frees are
> taking too long and hurting real-time tasks.
> 
> Could this be better solved by tweaking lazy_max_pages() such that purging is
> more aggressive?
> 
> Another approach could be to detect the scenario you brought up (allocations
> happening faster than free), somehow, and avoid a reschedule?
> 
This is what i am trying to achieve by this change. 

Thank you for your comments.

--
Vlad Rezki
> > 
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > ---
> >  mm/vmalloc.c | 18 ++++++++++++------
> >  1 file changed, 12 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index fb4fb5fcee74..abe83f885069 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -661,23 +661,27 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> >  	struct llist_node *valist;
> >  	struct vmap_area *va;
> >  	struct vmap_area *n_va;
> > -	bool do_free = false;
> > +	int resched_threshold;
> >  
> >  	lockdep_assert_held(&vmap_purge_lock);
> >  
> >  	valist = llist_del_all(&vmap_purge_list);
> > +	if (unlikely(valist == NULL))
> > +		return false;
> > +
> > +	/*
> > +	 * TODO: to calculate a flush range without looping.
> > +	 * The list can be up to lazy_max_pages() elements.
> > +	 */
> >  	llist_for_each_entry(va, valist, purge_list) {
> >  		if (va->va_start < start)
> >  			start = va->va_start;
> >  		if (va->va_end > end)
> >  			end = va->va_end;
> > -		do_free = true;
> >  	}
> >  
> > -	if (!do_free)
> > -		return false;
> > -
> >  	flush_tlb_kernel_range(start, end);
> > +	resched_threshold = (int) lazy_max_pages() << 1;
> >  
> >  	spin_lock(&vmap_area_lock);
> >  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> > @@ -685,7 +689,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> >  
> >  		__free_vmap_area(va);
> >  		atomic_sub(nr, &vmap_lazy_nr);
> > -		cond_resched_lock(&vmap_area_lock);
> > +
> > +		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> > +			cond_resched_lock(&vmap_area_lock);
> >  	}
> >  	spin_unlock(&vmap_area_lock);
> >  	return true;
> > -- 
> > 2.11.0
> > 


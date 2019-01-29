Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD490C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:18:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B77E2087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:18:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a1u6VfbH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B77E2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D6138E0002; Tue, 29 Jan 2019 11:18:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 183808E0001; Tue, 29 Jan 2019 11:18:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 026698E0002; Tue, 29 Jan 2019 11:18:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 867308E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:18:07 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 2-v6so6018803ljs.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:18:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zQ9HptmdOWJ9u9idVqDsmESiFBgfBiqm+pbhrVDO9qE=;
        b=OUp/9ARGRYr/0Q2MBDmzkJjucSDrbnDOEBQeURv0GS9s6kYoE6KnFTvblAzHU/GvXu
         3yW+1NtOYwPZ+oUZ2SDZBBiU1sHExyneHuRx1T0IcAXNQy0Rl1DqT2xp2a4GJyvl/AAY
         bCMdyIgS4v95NuEGHsTuKLXczLqrt9us4FTPQuKQYWhVrxGb9rT0hxKq+/jzgsf/n8qM
         ePxczi37zyYtGQAnbfrQ3XpdF1EiPc2eaDTo7+HpL7aExdEGVXfc2f75CjcErndpB1tH
         G4iQjdF12j5RyY6CSTg+CzoxGu29n5jMc5M+uH4cK1KrxzJZxk/WhT3cw2PU8Sh0UpkV
         ltKg==
X-Gm-Message-State: AJcUukf/OoRnUQihq5Lqxo7ds02KFvpoKGs9jxTGbGpnJvBTaSCLOUIT
	xmjC6Knx7N70/VUoU6KUPcpB+kr8Gg9fxQitAA/O13dhDiNpMtvWnzkZE6Ht0/j/rCKcDjOJwsj
	cxW/jKMrVF89CQpjYaPIflR5E3Fugfx2dfAXZjkL22uZydyHch1/oIhcyVosTS2116ecFqP7q8C
	U8uqqXyFv0y0KR72yYNmrzoV7SqqM0mwEEK4VF8vXpSENM/dyKyIxz1m9ZlM+9Yi6gOqxiX3PSw
	WMo2gYPRSyjfGOtisb2Pxsgu1DL6VuAG1K801xkxjjL8XtWDVFB6rqY+iNN6OjnT9vn/z5tQew5
	0/gjIN50sGUAlWdZTPH3IPjqPvc7knlWNf/7rWqmMY2WQfLEgMj9PUQWx3jv21sSSAtQprqtaEY
	x
X-Received: by 2002:a2e:9e16:: with SMTP id e22-v6mr21492284ljk.4.1548778686568;
        Tue, 29 Jan 2019 08:18:06 -0800 (PST)
X-Received: by 2002:a2e:9e16:: with SMTP id e22-v6mr21492230ljk.4.1548778685375;
        Tue, 29 Jan 2019 08:18:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548778685; cv=none;
        d=google.com; s=arc-20160816;
        b=Hz83uDdxwcCzdhMfryEjlY24OwG5Bu615UGJFzRJNSVKSPTNYNkuR9HNkiSvuMi+TJ
         /W6cvup9fxEmzXG2W56SO/OSOjCyaqbOrCT9dXhXJhDlfORRn9EwI5RiO7yEevelE8Gg
         KLBHhddqr7Dlyl3rBYYJC2RTKxh142m2VxQ3bDTm4qzIa8BM6iLUr1f7k/2sTrFyQith
         av5ByaRcUWGYkRlTkJWEHm9XqY8mV3zv8ClJepmZPLpRU3X2dyxzzzpuvBqtsc2fAyyb
         mumXWM3S20NkDjYtG+fQ/pTZBkUJYtf9ZInb2xSo7UMlZW8fltYxWQ+bAIUqY9YzlCWh
         Tvbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=zQ9HptmdOWJ9u9idVqDsmESiFBgfBiqm+pbhrVDO9qE=;
        b=yeHHoB/1qlnUFLAPkXZ13AmUNENnjALtFR4xhSGODRWsYAzsvBvYMpWquFh2lxZp2U
         SXzdzQ5YruuKUYSuqFi0Y7l8HBsAdEIt1b/G41bKCcisfyRwsOUQwXhZAN8nmPlGhdYx
         kjAjwrqKo8HWVD8msTSvs5XxrsOnqXRKAabtd1ZKt4FyId3O0Dm/ln/Ylu3X9+WyGnCK
         lIqapLoCqCcEseX7D7dbwpxcA0+LbvbMzgqn687Fu3dQj4ObVUyv9EkOqrqTP5OGLi+R
         nLICsQVVM/UNjk2LeVWJghaCkTHs5bf9PTFby3LW+j0kYpbSdpSd+bgCgu8eNcBXufOu
         HmpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a1u6VfbH;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h84sor5913606lfb.42.2019.01.29.08.18.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 08:18:05 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a1u6VfbH;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zQ9HptmdOWJ9u9idVqDsmESiFBgfBiqm+pbhrVDO9qE=;
        b=a1u6VfbHu0XhUBPA9meYk+NPYYvfrvLI3EffjAPM+xeblatTcIdmuwE16U85fJqHRR
         N+Yo2eSJ5GeJTJtgJgfL0Xwm0HNhKf7ZDqJQqoo+cockoPVGkEtJZLx5y9v7GT58YGkO
         N4urZ4CT1vFCWlPaUg6X2h2lwi6NHfhgVKce3BvGRRShEhgwQDPhljs2pspkShLfD4XV
         z5bNvK1VqKLslqvC16hKcZuyFQV1EWR1yP4pKSZyNGPFJjjgtY0G2cr52+iCB7d8Zb4C
         utpHNl/KE66ZFJnUXEN/t7XaIzoQ1o2PpX83KUmM2XxMJHP9fuS9Gr24lYV8gHU/4XCZ
         TtIQ==
X-Google-Smtp-Source: AHgI3IZU9GTIu2eWt3iCt52xb3nejqK0a2b3uXyjkGCOLMVKz7o+u7T3hQWCgTTA/SXIlvAi9SYf7w==
X-Received: by 2002:ac2:4243:: with SMTP id m3mr2329267lfl.5.1548778684646;
        Tue, 29 Jan 2019 08:18:04 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id x24-v6sm3974681ljc.54.2019.01.29.08.18.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 08:18:03 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 29 Jan 2019 17:17:54 +0100
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-ID: <20190129161754.phdr3puhp4pjrnao@pc636>
References: <20190124115648.9433-1-urezki@gmail.com>
 <20190124115648.9433-3-urezki@gmail.com>
 <20190128120429.17819bd348753c2d7ed3a7b9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128120429.17819bd348753c2d7ed3a7b9@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 12:04:29PM -0800, Andrew Morton wrote:
> On Thu, 24 Jan 2019 12:56:48 +0100 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
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
> It would be useful to credit the vmalloc test driver for this
> discovery, and perhaps to identify specifically which test triggered
> the kernel misbehaviour.  Please send along suitable words and I'll add
> them.
> 
Please see below more detail of testing:

<snip>
Using vmalloc test driver in "stress mode", i.e. When all available test
cases are run simultaneously on all online CPUs applying a pressure on the
vmalloc subsystem, my HiKey 960 board runs out of memory due to the fact
that __purge_vmap_area_lazy() logic simply is not able to free pages in
time.

How i run it:

1) You should build your kernel with CONFIG_TEST_VMALLOC=m
2) ./tools/testing/selftests/vm/test_vmalloc.sh stress

during this test "vmap_lazy_nr" pages will go far beyond acceptable
lazy_max_pages() threshold, that will lead to enormous busy list size
and other problems including allocation time and so on.
<snip>
> 
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
> 
> Why this change?
> 
I decided to refactor a bit, simplify and get rid of unneeded
do_free check logic. I think it is more straightforward just to
check if list is empty or not, instead of accessing to "do_free"
"n" times in a loop.

I can drop it, or upload as separate patch. What is your view?

> > +	/*
> > +	 * TODO: to calculate a flush range without looping.
> > +	 * The list can be up to lazy_max_pages() elements.
> > +	 */
> 
> How important is this?
> 
It depends on vmap_lazy_nr pages in the list we iterate. For example
on my ARM 8 cores with 4Gb system i see that __purge_vmap_area_lazy()
can take up to 12 milliseconds because of long list. That is why there
is the cond_resched_lock().

As for this first loop's time execution, it takes ~4/5 milliseconds to
find out the flush range. Probably it is not so important since it is
not done in atomic context means it can be interrupted or preempted.
So, it will increase execution time of the current process that does:

vfree()/etc -> __purge_vmap_area_lazy().

From the other hand if we could calculate that range in runtime, i
mean when we add a VA to the vmap_purge_list checking va->va_start
and va->va_end with min/max we could get rid of that loop. But this
is just an idea.

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
> 
> Is the typecast really needed?
> 
> Perhaps resched_threshold shiould have unsigned long type and perhaps
> vmap_lazy_nr should be atomic_long_t?
> 
I think so. Especially that atomit_t is 32 bit integer value on both 32
and 64 bit systems. lazy_max_pages() deals with unsigned long that is 8
bytes on 64 bit system, thus vmap_lazy_nr should be 8 bytes on 64 bit
as well.

Should i send it as separate patch? What is your view?

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
> 

Thank you for your comments and review.

--
Vlad Rezki


Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F207EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 02:38:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 976E6222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 02:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 976E6222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 197338E0002; Wed, 13 Feb 2019 21:38:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147CF8E0001; Wed, 13 Feb 2019 21:38:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036148E0002; Wed, 13 Feb 2019 21:38:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCE258E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 21:38:13 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p5so4329543qtp.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:38:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EL2EreK6yxsWIZVuyW7ZRBytPZKu6ZPSvXQYs/Ld7/M=;
        b=Ryu0RdU3O+AQ4fr8C3qRCidM4uOITskSX0rATB1tmpvAp/abGwuejXtvvaksDbk0F6
         qZNFGcJ/DUddgkOkaz8ZeAgs1JR5x81ZWYJhY9sxjPv27T+zat6kV0LdNKmC0XG7PG4T
         n9Z5tCj08Zem60KPbo7RWtGpCNX0G/IuHi7J48O+wARfhgZ4Kwp+L4OHJlYLyp1M8dpe
         9oDRaq6xGb3ZoFXxxPUunnrdP5wpcgIi5ifPtICV7rAa3ZbpU4/77g2bUmIDtmlOrb+e
         zv4Pnwt1RN9S5TrS8117E2AfSKJYMrKLjHuZY4yN1/lIWEe15o3sByU/tiLZoZAAPzWa
         ljLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZfdroIeWXtsXKPZksgb132PFr7gdKq3OVeR33LfO//eXYwcbHL
	GIkRtQJu/fFKAXCnCS9s/vzfHbJyO8mMTLTwm42o9EM2g3NePgfSTugt6jpLxpAchAicZWLLAlY
	HcwLb99fYLzIiSTzpqyQ0qPP92YNjwy5hobAXqZ9fs46oA/cAS8UCye2aTihRRis6ug==
X-Received: by 2002:a37:6105:: with SMTP id v5mr1025759qkb.63.1550111893604;
        Wed, 13 Feb 2019 18:38:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCQnZwK9DMBRkVKokf29Z9jpGGyZnOPkCCVHpteW0Ucd7MiBHGRxIBzzEFsJXTB9KKdoHe
X-Received: by 2002:a37:6105:: with SMTP id v5mr1025722qkb.63.1550111892768;
        Wed, 13 Feb 2019 18:38:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550111892; cv=none;
        d=google.com; s=arc-20160816;
        b=ttTKDn+RdA5BXHoMna6crKmTByFOPaoR0OU8HMGDdPcSdlEZMSanvr672hiB88sN3z
         E7lBO0BKSE2F7SRzqQUrpPI4RSfhcaLES9KxTvie1Ng0etw4wuTRdx/QVAAwHuzEiq6D
         aFDMRy5ZmdxrcCoNJQI9GWOFSdrTXB7oMwWgsLIXqjfV7uAPbuKNKHhorfJJiALN4PET
         gqzn3laPnZDchFU8lMc3A4TpyYg1PFYJrWSL1cjhOMykddmomnuf52vU+7YJdwgiWiTO
         9PAFS3BQoIECr/vtlp2mwGFLxjx5ZWT3e0T3Smf7m6IGkciqDxfMOPfCrI5+PHpZ3tZ2
         ncfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EL2EreK6yxsWIZVuyW7ZRBytPZKu6ZPSvXQYs/Ld7/M=;
        b=f8ZTX7epFa4TS4mECAtJAgJ8yNCMiI+JiIa9aj1Z9kyXs4FpmC7Fw5/S79iTTmaCLQ
         mv2rAv+j52s3uQ06JIv7CCoHnAbKvN+seV+NCL+vOIukwEfV90xkQTkIVTEu7MvdpIkS
         +d7lNbwo87O0Io4qlfCGI6JEdVjyachAGmOuz7LPM+cqR+M6WSUr2pX5QOOPCsl+YGNz
         ArHHSwqrr0w9980yFa2u82p0JNhOA23S7v30XUVx9T527CoVHw+NyL9Rmu30u9+/dTW5
         U7hpy5qFkyomw9kCcjbvGkWJcyn5CQxuPh8dw92tbYGMzMhnNrOUDnw1FhvHMnDLYeIx
         KVIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g92si727114qva.34.2019.02.13.18.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 18:38:12 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9014DC049D67;
	Thu, 14 Feb 2019 02:38:10 +0000 (UTC)
Received: from sky.random (ovpn-120-178.rdu2.redhat.com [10.10.120.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 97FC25D6B3;
	Thu, 14 Feb 2019 02:38:06 +0000 (UTC)
Date: Wed, 13 Feb 2019 21:38:05 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190214023805.GA19090@redhat.com>
References: <20190211083846.18888-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211083846.18888-1-ying.huang@intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 14 Feb 2019 02:38:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

On Mon, Feb 11, 2019 at 04:38:46PM +0800, Huang, Ying wrote:
> @@ -2386,7 +2463,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
>  	frontswap_init(p->type, frontswap_map);
>  	spin_lock(&swap_lock);
>  	spin_lock(&p->lock);
> -	 _enable_swap_info(p, prio, swap_map, cluster_info);
> +	setup_swap_info(p, prio, swap_map, cluster_info);
> +	spin_unlock(&p->lock);
> +	spin_unlock(&swap_lock);
> +	/*
> +	 * Guarantee swap_map, cluster_info, etc. fields are used
> +	 * between get/put_swap_device() only if SWP_VALID bit is set
> +	 */
> +	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);

Should cpu_online_mask be read while holding cpus_read_lock?

	cpus_read_lock();
	err = __stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
	cpus_read_unlock();

I missed what the exact motivation was for the switch from
rcu_read_lock()/syncrhonize_rcu() to preempt_disable()/stop_machine().

It looks like the above stop_machine all it does is to reach a
quiescent point, when you've RCU that already can reach the quiescent
point without an explicit stop_machine.

The reason both implementations are basically looking the same is that
stop_machine dummy call of swap_onoff_stop() { /* noop */ } will only
reach a quiescent point faster than RCU, but it's otherwise
functionally identical to RCU, but it's extremely more expensive. If
it wasn't functionally identical stop_machine() couldn't be used as a
drop in replacement of synchronize_sched() in the previous patch.

I don't see the point of worrying about the synchronize_rcu latency in
swapoff when RCU is basically identical and not more complex.

So to be clear, I'm not against stop_machine() but with stop_machine()
method invoked in all CPUs, you can actually do more than RCU and you
can remove real locking not just reach a quiescent point.

With stop_machine() the code would need reshuffling around so that the
actual p->swap_map = NULL happens inside stop_machine, not outside
like with RCU.

With RCU all code stays concurrent at all times, simply the race is
controlled, as opposed with stop_machine() you can make fully
serialize and run like in UP temporarily (vs all preempt_disable()
section at least).

For example nr_swapfiles could in theory become a constant under
preempt_disable() with stop_machine() without having to take a
swap_lock.

swap_onoff_stop can be implemented like this:

enum {
	FIRST_STOP_MACHINE_INIT,
	FIRST_STOP_MACHINE_START,
	FIRST_STOP_MACHINE_END,
};
static int first_stop_machine;
static int swap_onoff_stop(void *data)
{
	struct swap_stop_machine *swsm = (struct swap_stop_machine *)data;
	int first;

	first = cmpxchg(&first_stop_machine, FIRST_STOP_MACHINE_INIT,
			FIRST_STOP_MACHINE_START);
	if (first == FIRST_STOP_MACHINE_INIT) {
		swsm->p->swap_map = NULL;
		/* add more stuff here until swap_lock goes away */
		smp_wmb();
		WRITE_ONCE(first_stop_machine, FIRST_STOP_MACHINE_END);
	} else {
		do {
			cpu_relax();
		} while (READ_ONCE(first_stop_machine) !=
			 FIRST_STOP_MACHINE_END);
		smp_rmb();
	}

	return 0;
}

stop_machine invoked with a method like above, will guarantee while we
set p->swap_map to NULL (and while we do nr_swapfiles++) nothing else
can run, no even interrupts, so some lock may just disappear. Only NMI
and SMI could possibly run concurrently with the swsm->p->swap_map =
NULL operation.

If we've to keep swap_onoff_stop() a dummy function run on all CPUs
just to reach a quiescent point, then I don't see why
the synchronize_rcu() (or synchronize_sched or synchronize_kernel or
whatever it is called right now, but still RCU) solution isn't
preferable.

Thanks,
Andrea


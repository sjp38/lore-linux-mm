Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0A1B6B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:28:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so2627973wrf.0
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:28:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si1337852edc.108.2017.09.15.07.28.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 07:28:27 -0700 (PDT)
Date: Fri, 15 Sep 2017 16:28:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
Message-ID: <20170915142823.jlhsba6rdhx5glfe@dhcp22.suse.cz>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
 <b8d952c5-2803-eea2-cd9a-20463a48075e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8d952c5-2803-eea2-cd9a-20463a48075e@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Kemi Wang <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 15-09-17 07:16:23, Dave Hansen wrote:
> On 09/15/2017 04:49 AM, Michal Hocko wrote:
> > Why do we need an auto-mode? Is it safe to enforce by default.
> 
> Do we *need* it?  Not really.
> 
> But, it does offer the best of both worlds: The vast majority of users
> see virtually no impact from the counters.  The minority that do need
> them pay the cost *and* don't have to change their tooling at all.

Just to make it clear, I am not really opposing. It just adds some code
which we can safe... It is also rather chatty for something that can be
true/false.
 
> > Is it> possible that userspace can get confused to see 0 NUMA stats in
> the
> > first read while other allocation stats are non-zero?
> 
> I doubt it.  Those counters are pretty worthless by themselves.  I have
> tooling that goes and reads them, but it aways displays deltas.  Read
> stats, sleep one second, read again, print the difference.

This is how I use them as well.
 
> The only scenario I can see mattering is someone who is seeing a
> performance issue due to NUMA allocation misses (or whatever) and wants
> to go look *back* in the past.

yes

> A single-time printk could also go a long way to keeping folks from
> getting confused.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

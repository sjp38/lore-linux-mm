Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9BBC6B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:16:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so4971728pgh.0
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:16:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h14si765102plk.375.2017.09.15.07.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 07:16:24 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b8d952c5-2803-eea2-cd9a-20463a48075e@linux.intel.com>
Date: Fri, 15 Sep 2017 07:16:23 -0700
MIME-Version: 1.0
In-Reply-To: <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 09/15/2017 04:49 AM, Michal Hocko wrote:
> Why do we need an auto-mode? Is it safe to enforce by default.

Do we *need* it?  Not really.

But, it does offer the best of both worlds: The vast majority of users
see virtually no impact from the counters.  The minority that do need
them pay the cost *and* don't have to change their tooling at all.

> Is it> possible that userspace can get confused to see 0 NUMA stats in
the
> first read while other allocation stats are non-zero?

I doubt it.  Those counters are pretty worthless by themselves.  I have
tooling that goes and reads them, but it aways displays deltas.  Read
stats, sleep one second, read again, print the difference.

The only scenario I can see mattering is someone who is seeing a
performance issue due to NUMA allocation misses (or whatever) and wants
to go look *back* in the past.

A single-time printk could also go a long way to keeping folks from
getting confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

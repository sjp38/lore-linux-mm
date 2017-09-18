Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA6D6B0069
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:50:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so8270417wrf.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:50:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si895060edi.385.2017.09.17.22.50.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 22:50:28 -0700 (PDT)
Date: Mon, 18 Sep 2017 07:50:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
Message-ID: <20170918055023.ikvocc5q4i4rmq2p@dhcp22.suse.cz>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
 <8cb99df9-3db3-99fc-8fc1-c9f14b2d9017@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8cb99df9-3db3-99fc-8fc1-c9f14b2d9017@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon 18-09-17 11:22:37, kemi wrote:
> 
> 
> On 2017a1'09ae??15ae?JPY 19:49, Michal Hocko wrote:
> > On Fri 15-09-17 17:23:24, Kemi Wang wrote:
> >> This patch adds a tunable interface that allows VM stats configurable, as
> >> suggested by Dave Hansen and Ying Huang.
> >>
> >> When performance becomes a bottleneck and you can tolerate some possible
> >> tool breakage and some decreased counter precision (e.g. numa counter), you
> >> can do:
> >> 	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
> >>
> >> When performance is not a bottleneck and you want all tooling to work, you
> >> can do:
> >> 	echo [S|s]trict > /proc/sys/vm/vmstat_mode
> >>
> >> We recommend automatic detection of virtual memory statistics by system,
> >> this is also system default configuration, you can do:
> >> 	echo [A|a]uto > /proc/sys/vm/vmstat_mode
> >>
> >> The next patch handles numa statistics distinctively based-on different VM
> >> stats mode.
> > 
> > I would just merge this with the second patch so that it is clear how
> > those modes are implemented. I am also wondering why cannot we have a
> > much simpler interface and implementation to enable/disable numa stats
> > (btw. sysctl_vm_numa_stats would be more descriptive IMHO).
> > 
> 
> Apologize for resending it, because I found my previous reply mixed with
> Michal's in many email client.
> 
> The motivation is that we propose a general tunable  interface for VM stats.
> This would be more scalable, since we don't have to add an individual
> Interface for each type of counter that can be configurable.

Can you envision which other counters would fall into the same category?

> In the second patch, NUMA stats, as an example, can benefit for that.
> If you still hold your idea, I don't mind to merge them together.

Well, I would prefer simplicy in the first place.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

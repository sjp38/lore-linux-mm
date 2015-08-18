Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id BC7B16B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:14:09 -0400 (EDT)
Received: by igui7 with SMTP id i7so70336964igu.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:14:09 -0700 (PDT)
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com. [209.85.213.179])
        by mx.google.com with ESMTPS id q6si8529821igr.43.2015.08.17.17.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:14:09 -0700 (PDT)
Received: by igui7 with SMTP id i7so70336852igu.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:14:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439781546-7217-5-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
	<1439781546-7217-5-git-send-email-jiang.liu@linux.intel.com>
Date: Mon, 17 Aug 2015 17:14:08 -0700
Message-ID: <CALnjE+pTMo2E2CSswzbSeTPONvUQ8d_+Z1UbGVKMEZcSCjtA=A@mail.gmail.com>
Subject: Re: [Patch V3 4/9] openvswitch: Replace cpu_to_node() with
 cpu_to_mem() to support memoryless node
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, netdev <netdev@vger.kernel.org>, "dev@openvswitch.org" <dev@openvswitch.org>

On Sun, Aug 16, 2015 at 8:19 PM, Jiang Liu <jiang.liu@linux.intel.com> wrote:
> Function ovs_flow_stats_update() allocates memory with __GFP_THISNODE
> flag set, which may cause permanent memory allocation failure on
> memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
> support memoryless node. For node with memory, cpu_to_mem() is the same
> as cpu_to_node().
>
> This change only affects performance and shouldn't affect functionality.
>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

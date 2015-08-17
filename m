Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 13EBA6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:35:48 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so51469592qkd.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:35:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p91si27395308qkh.66.2015.08.17.14.35.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 14:35:47 -0700 (PDT)
Date: Mon, 17 Aug 2015 14:35:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch V3 0/9] Enable memoryless node support for x86
Message-Id: <20150817143545.577a1758d29cf137d5c3d345@linux-foundation.org>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Mon, 17 Aug 2015 11:18:57 +0800 Jiang Liu <jiang.liu@linux.intel.com> wrote:

> This is the third version to enable memoryless node support on x86
> platforms.

I'll grab this for inclusion in linux-next after the 4.2 release.

It's basically an x86 patch so if someone else was planning on looking
after it, please tell me off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

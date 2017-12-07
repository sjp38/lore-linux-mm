Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8736B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:06:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k104so3104656wrc.19
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:06:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2si3105664wrn.67.2017.12.06.17.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 17:06:38 -0800 (PST)
Date: Wed, 6 Dec 2017 17:06:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/15] mm: memcontrol: fix excessive complexity in
 memory.stat reporting
Message-Id: <20171206170635.e3e45c895750538ee9283033@linux-foundation.org>
In-Reply-To: <20171201135750.GB8097@cmpxchg.org>
References: <5a208303.hxMsAOT0gjSsd0Gf%akpm@linux-foundation.org>
	<20171201135750.GB8097@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, vdavydov.dev@gmail.com

On Fri, 1 Dec 2017 13:57:50 +0000 Johannes Weiner <hannes@cmpxchg.org> wrote:

> The memcg cpu_dead callback can be called early during startup
> (CONFIG_DEBUG_HOTPLUG_CPU0) with preemption enabled, which triggers a
> warning in its __this_cpu_xchg() calls. But CPU locality is always
> guaranteed, which is the only thing we really care about here.
> 
> Using the preemption-safe this_cpu_xchg() addresses this problem.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> Andrew, can you please merge this fixlet into the original patch?

Did.

I see that lkp-robot identified a performance regression and pointed
the finger at this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D6653280340
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 16:19:02 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so66858784pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 13:19:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sd2si20343753pbb.59.2015.07.17.13.19.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 13:19:01 -0700 (PDT)
Date: Fri, 17 Jul 2015 13:19:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-Id: <20150717131900.5b0b5d91597d207c474be7a5@linux-foundation.org>
In-Reply-To: <20150717151827.GB15934@mtj.duckdns.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
	<1436958885-18754-2-git-send-email-mhocko@kernel.org>
	<20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
	<20150716071948.GC3077@dhcp22.suse.cz>
	<20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
	<20150716225639.GA11131@cmpxchg.org>
	<20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
	<20150717122819.GA14895@cmpxchg.org>
	<20150717151827.GB15934@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 17 Jul 2015 11:18:27 -0400 Tejun Heo <tj@kernel.org> wrote:

> Maybe there are details to be improved but I think
> it's about time mem_cgroup definition gets published.

grumble.

enum mem_cgroup_events_target can remain private to memcontrol.c.  It's
only used by mem_cgroup_event_ratelimit() and that function is static.

Why were cg_proto_flags and cg_proto moved from include/net/sock.h?

struct mem_cgroup_stat_cpu can remain private to memcontrol.c.  Forward
declare the struct in memcontrol.h.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

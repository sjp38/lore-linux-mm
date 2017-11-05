Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E724B6B0253
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 02:45:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 15so8720820pgc.16
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 00:45:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si8402404plp.765.2017.11.05.00.45.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Nov 2017 00:45:12 -0700 (PDT)
Date: Sun, 5 Nov 2017 08:45:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v2] mm: drop hotplug lock from lru_add_drain_all
Message-ID: <20171105074509.fmkki36il5h45vru@dhcp22.suse.cz>
References: <20171102093613.3616-1-mhocko@kernel.org>
 <20171102093613.3616-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102093613.3616-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>

Here is v2 which drops the IRQ disabling in the hotplug callback and
fixes the compile breakage. The patch 1 is wrong as pointed out by Hugh,
but this one alone should help already.
---

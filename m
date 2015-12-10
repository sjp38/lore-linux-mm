Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id A37FA6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:50:24 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id n186so2839105wmn.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:50:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wz10si21200652wjc.58.2015.12.10.12.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 12:50:23 -0800 (PST)
Date: Thu, 10 Dec 2015 15:50:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/8 v2] mm: memcontrol: move kmem accounting code to
 CONFIG_MEMCG
Message-ID: <20151210205011.GA4967@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
 <20151210202244.GA4809@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210202244.GA4809@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Arnd Bergmann <arnd@arndb.de>

Narf. Almost there...

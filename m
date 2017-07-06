Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3BAC6B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 14:00:02 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id y70so2917771vky.5
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 11:00:02 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id o77si29271vkd.150.2017.07.06.11.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 11:00:01 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id 191so4817979vko.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 11:00:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706171658.mohgkjcefql4wekz@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net> <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net> <20170706164304.GA23662@castle>
 <20170706171658.mohgkjcefql4wekz@techsingularity.net>
From: Debabrata Banerjee <dbavatar@gmail.com>
Date: Thu, 6 Jul 2017 14:00:00 -0400
Message-ID: <CAATkVEw22YAfSH4GKY1Y9Qz9chCAz1cgcesz_xg3O2-0XxY_ng@mail.gmail.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 6, 2017 at 1:16 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> I'm still struggling to see how counters help when an agent that monitors
> for high CPU usage could be activated
>

I suspect Roman has the same problem set as us, the CPU usage is
either always high, high and service critical likely when something
interesting is happening. We'd like to collect data on 200k machines,
and study the results statistically and with respect to time based on
kernel versions, build configs, hardware types, process types, load
patterns, etc, etc. Even finding good candidate machines and at the
right time of day to manually debug with ftrace is problematic.
Granted we could be utilizing existing counters like compact_fail
better. Ultimately the data either leads to dealing with certain bad
actors, different vm tunings, or patches to mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 227D06B00BF
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 05:52:05 -0400 (EDT)
Date: Tue, 11 Sep 2012 11:52:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
Message-ID: <20120911095200.GB8058@dhcp22.suse.cz>
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sachin Kamat <sachin.kamat@linaro.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 11-09-12 13:38:54, Sachin Kamat wrote:
> net/sock.h is included unconditionally at the beginning of the file.
> Hence, another conditional include is not required.

I guess we can do little bit better. What do you think about the
following?  I have compile tested this with:
- CONFIG_INET=y && CONFIG_MEMCG_KMEM=n
- CONFIG_MEMCG_KMEM=y
---

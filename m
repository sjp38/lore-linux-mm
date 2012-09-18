Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9BFCC6B0072
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 05:13:06 -0400 (EDT)
Date: Tue, 18 Sep 2012 11:13:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: move mem_cgroup_is_root upwards (was Re: +
 memcg-cleanup-kmem-tcp-ifdefs.patch added to -mm tree)
Message-ID: <20120918091304.GA13936@dhcp22.suse.cz>
References: <20120917222052.240CC200057@hpza10.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120917222052.240CC200057@hpza10.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, glommer@parallels.com, sachin.kamat@linaro.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
could you add the patch bellow on top of memcg-cleanup-kmem-tcp-ifdefs.patch?
They are not directly related (that's why I didn't post it as a series)
but this one depend on the changed context (and it makes my old compiler much
happier).
---

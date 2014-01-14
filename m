Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 644796B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 01:53:22 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id n15so1877105lbi.11
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 22:53:21 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si10599038lby.37.2014.01.13.22.53.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 22:53:20 -0800 (PST)
Message-ID: <52D4DED7.8090702@parallels.com>
Date: Tue, 14 Jan 2014 10:53:11 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: vmscan: move call to shrink_slab() to shrink_zones()
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com> <1e31dd389002eca2533e6b112a774855426b1703.1389443272.git.vdavydov@parallels.com> <20140113151334.996da9f248db297faeed1ed1@linux-foundation.org>
In-Reply-To: <20140113151334.996da9f248db297faeed1ed1@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>

On 01/14/2014 03:13 AM, Andrew Morton wrote:
> On Sat, 11 Jan 2014 16:36:34 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> This reduces the indentation level of do_try_to_free_pages() and removes
>> extra loop over all eligible zones counting the number of on-LRU pages.
> So this should cause no functional change, yes?

Yes. This patch merely moves a piece of code from one function to another.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

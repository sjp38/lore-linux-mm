Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0470D6B006E
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:10:36 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so3578248yho.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:10:36 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id l5si13018624yhl.299.2013.12.10.00.10.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 00:10:35 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y10so6890619pdj.9
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:10:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <71c7c5bbcad2e29f81eaf9eaad36c120815125c8.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
	<71c7c5bbcad2e29f81eaf9eaad36c120815125c8.1386571280.git.vdavydov@parallels.com>
Date: Tue, 10 Dec 2013 12:10:34 +0400
Message-ID: <CAA6-i6oO71Ja3z4dAsawTmsNm_FkzmU-LWvq70X+X9JTMDSSiA@mail.gmail.com>
Subject: Re: [PATCH v13 05/16] vmscan: move call to shrink_slab() to shrink_zones()
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Mon, Dec 9, 2013 at 12:05 PM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> This reduces the indentation level of do_try_to_free_pages() and removes
> extra loop over all eligible zones counting the number of on-LRU pages.
>

Looks correct to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

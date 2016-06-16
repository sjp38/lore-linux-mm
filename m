Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA8E6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:41:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so28520388wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:41:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ei6si5713054wjd.205.2016.06.16.07.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 07:41:14 -0700 (PDT)
Date: Thu, 16 Jun 2016 10:41:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160616144102.GA17692@cmpxchg.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <20160613150653.GA30642@cmpxchg.org>
 <20160615004027.GA17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615004027.GA17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>

On Wed, Jun 15, 2016 at 09:40:27AM +0900, Minchan Kim wrote:
> A question is it seems cgroup2 doesn't have per-cgroup swappiness.
> Why?
> 
> I think we need it in one-cgroup-per-app model.

Can you explain why you think that?

As we have talked about this recently in the LRU balancing thread,
swappiness is the cost factor between file IO and swapping, so the
only situation I can imagine you'd need a memcg swappiness setting is
when you have different cgroups use different storage devices that do
not have comparable speeds.

So I'm not sure I understand the relationship to an app-group model.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

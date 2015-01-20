Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAF26B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 11:57:20 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so16271290wiw.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 08:57:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si6568926wiw.32.2015.01.20.08.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 08:57:17 -0800 (PST)
Date: Tue, 20 Jan 2015 17:57:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/2] mm: memcontrol: default hierarchy interface for
 memory v2
Message-ID: <20150120165716.GP25342@dhcp22.suse.cz>
References: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

And one more thing. Maybe we should consider posting this to linux-api
as well. This is a new user visible interface and it would be good to
have more eyes looking at possible shortcomings.

On Tue 20-01-15 10:31:53, Johannes Weiner wrote:
> Hi Andrew,
> 
> these patches changed sufficiently while in -mm that a rebase makes
> sense.  The change from using "none" in the configuration files to
> "max"/"infinity" requires a do-over of 1/2 and a changelog fix in 2/2.
> 
> I folded all increments, both in-tree and the ones still pending, and
> credited your seq_puts() checkpatch fix, so these two changes are the
> all-encompassing latest versions, and everything else can be dropped.
> 
> Thanks!
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

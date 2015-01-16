Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id E50116B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 14:17:50 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id rd18so22320508iec.8
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 11:17:50 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id ad2si2506510igd.12.2015.01.16.11.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 11:17:49 -0800 (PST)
Date: Fri, 16 Jan 2015 13:17:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150116175745.GA22136@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501161317001.19117@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <20150116175745.GA22136@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Fri, 16 Jan 2015, Michal Hocko wrote:

> On Fri 16-01-15 16:49:22, Michal Hocko wrote:
> [...]
> > Why cannot we simply update the global counters from vmstat_shepherd
> > directly?
>
> OK, I should have checked the updating paths... This would be racy, so
> update from remote is not an option without additional trickery (like
> retries etc.) :/

You can do that if you have a way to ensure that the other cpu does not
access the counter. F.e. if the other cpu is staying in user space all the
time or it is guaranteed to be idle.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

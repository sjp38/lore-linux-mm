Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 56E426B0032
	for <linux-mm@kvack.org>; Sat, 17 Jan 2015 14:48:38 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id q107so7098705qgd.1
        for <linux-mm@kvack.org>; Sat, 17 Jan 2015 11:48:38 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id o92si2745853qge.107.2015.01.17.11.48.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 17 Jan 2015 11:48:37 -0800 (PST)
Date: Sat, 17 Jan 2015 13:48:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <54BA7D3A.40100@codeaurora.org>
Message-ID: <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Sat, 17 Jan 2015, Vinayak Menon wrote:

> which had not updated the vmstat_diff. This CPU was in idle for around 30
> secs. When I looked at the tvec base for this CPU, the timer associated with
> vmstat_update had its expiry time less than current jiffies. This timer had
> its deferrable flag set, and was tied to the next non-deferrable timer in the

We can remove the deferrrable flag now since the vmstat threads are only
activated as necessary with the recent changes. Looks like this could fix
your issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

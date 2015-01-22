Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id C18246B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 11:11:34 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id vy18so2175781iec.5
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:11:34 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id fs8si4425icb.105.2015.01.22.08.11.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 08:11:34 -0800 (PST)
Date: Thu, 22 Jan 2015 10:11:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150121143920.GD23700@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501221010510.3937@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <54BC879C.90505@codeaurora.org> <20150121143920.GD23700@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Wed, 21 Jan 2015, Michal Hocko wrote:

> I think we can solve this as well. We can stick vmstat_shepherd into a
> kernel thread with a loop with the configured timeout and then create a
> mask of CPUs which need the update and run vmstat_update from
> IPI context (smp_call_function_many).

Please do not run the vmstat_updates concurrently. They update shared
cachelines and therefore can cause bouncing cachelines if run concurrently
on multiple cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

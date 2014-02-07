Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A4E2E6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:07:10 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id m15so2429333wgh.2
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:07:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si1782949wiy.36.2014.02.07.09.07.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:07:09 -0800 (PST)
Date: Fri, 7 Feb 2014 18:07:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/8] memcg: charge path cleanups
Message-ID: <20140207170708.GI5121@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:17, Johannes Weiner wrote:
> Hi Michal,
> 
> I took some of your patches and combined them with the charge path
> cleanups I already had and the changes I made after our discussion.
> 
> I'm really happy about where this is going:
> 
>  mm/memcontrol.c | 298 ++++++++++++++++--------------------------------------
>  1 file changed, 87 insertions(+), 211 deletions(-)

The diffstat looks really nice. I will not get to the patches earlier
than on Monday.

> let me know what you think!
> 
> Johannes
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

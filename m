Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A20E66B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 11:55:25 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so8334679wgh.4
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:55:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id am4si18679984wjc.165.2014.03.10.08.55.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 08:55:24 -0700 (PDT)
Date: Mon, 10 Mar 2014 16:55:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/8] memcg: charge path cleanups
Message-ID: <20140310155523.GF5171@dhcp22.suse.cz>
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
> 
> let me know what you think!
> 
> Johannes
 
What's happened with this series? Are you planning to repost it
Johannes? I know it is late in the cycle but it would be nice to have it
at least in mmotm tree because it shuffles the code a lot.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

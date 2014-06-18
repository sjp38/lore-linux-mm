Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 691836B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:31:33 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so1388982wgh.19
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:31:32 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fl5si4123620wib.71.2014.06.18.13.31.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:31:32 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:31:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/12] mm: memcontrol: naturalize charge lifetime v3
Message-ID: <20140618203124.GF7331@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <20140617163615.GD9572@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617163615.GD9572@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 17, 2014 at 06:36:15PM +0200, Michal Hocko wrote:
> On Mon 16-06-14 15:54:20, Johannes Weiner wrote:
> > Hi,
> > 
> > this is v3 of the memcg charge naturalization series.  Changes since
> > v2 include:
> > 
> > o make THP charges use __GFP_NORETRY to prevent excessive reclaim (Michal)
> > o simplify move precharging while in the area
> > o add acks & rebase to v3.16-rc1
> 
> I still didn't get to the last two patches and they need a more
> throughout review. The rest is good and nice on its own and maybe it
> would be easier if those go in first.
> 
> I would like to get to the last two ASAP but this is heavier and I am
> quite swamped by other small tasks last weeks so I do not want to delay
> the whole series.

The merge window just opened so I don't think we are in an extreme
rush to get those in.

If you're worried about conflicts, I think the most potential for that
would be in the last two patches, so not much is saved in that regard
by taking the series apart.

I'm just going to resend the latest version with the acks you already
provided, and then Andrew can decide whether he wants to take the last
two as well right away, depending on testing and conflict resolution
preferences and on how optimistic he is that you'll agree with them ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD506B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 03:58:36 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so3397951pdi.9
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 00:58:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h4si1774469pat.135.2015.01.07.00.58.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 00:58:34 -0800 (PST)
Date: Wed, 7 Jan 2015 11:58:28 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150107085828.GA2110@esperanza>
References: <20150106161435.GF20860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150106161435.GF20860@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 06, 2015 at 05:14:35PM +0100, Michal Hocko wrote:
[...]
> And as a memcg co-maintainer I would like to also discuss the following
> topics.
> - We should finally settle down with a set of core knobs exported with
>   the new unified hierarchy cgroups API. I have proposed this already
>   http://marc.info/?l=linux-mm&m=140552160325228&w=2 but there is no
>   clear consensus and the discussion has died later on. I feel it would
>   be more productive to sit together and come up with a reasonable
>   compromise between - let's start from the begining and keep useful and
>   reasonable features.
>   
> - kmem accounting is seeing a lot of activity mainly thanks to Vladimir.
>   He is basically the only active developer in this area. I would be
>   happy if he can attend as well and discuss his future plans in the
>   area. The work overlaps with slab allocators and slab shrinkers so
>   having people familiar with these areas would be more than welcome

One more memcg related topic that is worth discussing IMO:

 - On global memory pressure we walk over all memory cgroups and scan
   pages from each of them. Since there can be hundreds or even
   thousands of memory cgroups, such a walk can be quite expensive,
   especially if the cgroups are small so that to reclaim anything from
   them we have to descend to a lower scan priority. The problem is
   augmented by offline memory cgroups, which now can be dangling for
   indefinitely long time.

   That's why I think we should work out a better algorithm for the
   memory reclaimer. May be, we could rank memory cgroups somehow (by
   their age, memory consumption?) and try to scan only the top ranked
   cgroup during a reclaimer run. This topic is also very close to the
   soft limit reclaim improvements, which Michal has been working on for
   a while.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

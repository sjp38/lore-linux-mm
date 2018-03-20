Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31BB16B000E
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:45:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m198so1584072pga.4
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:45:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20-v6sor1196717pll.47.2018.03.20.15.45.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 15:45:29 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:45:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: =?UTF-8?Q?Re=3A_=E7=AD=94=E5=A4=8D=3A_=E7=AD=94=E5=A4=8D=3A_=5BPATCH=5D_mm=2Fmemcontrol=2Ec=3A_speed_up_to_force_empty_a_memory_cgroup?=
In-Reply-To: <e265c518-968b-8669-ad22-671c781ad96e@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1803201540290.45142@chino.kir.corp.google.com>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com> <20180319085355.GQ23100@dhcp22.suse.cz> <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com> <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com> <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com> <20180320083950.GD23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803201327060.167205@chino.kir.corp.google.com>
 <56508bd0-e8d7-55fd-5109-c8dacf26b13e@virtuozzo.com> <alpine.DEB.2.20.1803201514340.14003@chino.kir.corp.google.com> <e265c518-968b-8669-ad22-671c781ad96e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 21 Mar 2018, Andrey Ryabinin wrote:

> > Is SWAP_CLUSTER_MAX the best answer if I'm lowering the limit by 1GB?
> > 
> 
> Absolutely not. I completely on your side here. 
> I've tried to fix this recently - http://lkml.kernel.org/r/20180119132544.19569-2-aryabinin@virtuozzo.com
> I guess that Andrew decided to not take my patch, because Michal wasn't
> happy about it (see mail archives if you want more details).
> 

I unfortunately didn't see this patch in January, it seems very similar to 
what I was suggesting in this thread.  You do a page_counter_read() 
directly in mem_cgroup_resize_limit() where my suggestion was to have 
page_counter_limit() return the difference, but there's nothing 
significantly different about what you proposed and what I suggested.

Perhaps the patch would be better off as a compromise between what you, I, 
and Li RongQing have proposed/suggested: have page_counter_limit() return 
the difference, and clamp it to some value proportional to the new limit.

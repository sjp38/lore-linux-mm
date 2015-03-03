Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 91A626B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 14:54:12 -0500 (EST)
Received: by obcva2 with SMTP id va2so2124817obc.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 11:54:12 -0800 (PST)
Received: from smtp_126.52 ([220.181.19.144])
        by mx.google.com with ESMTP id cd3si938618oec.16.2015.03.03.11.54.11
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 11:54:12 -0800 (PST)
Message-ID: <54F61300.1070409@sohu.com>
Date: Wed, 04 Mar 2015 04:01:04 +0800
From: Chen Gang <dsg_gchen_5257@sohu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memcontrol: Let mem_cgroup_move_account() have effect
 only if MMU enabled
References: <54F4E739.6040805@qq.com> <20150303134524.GE2409@dhcp22.suse.cz>
In-Reply-To: <20150303134524.GE2409@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Chen Gang <762976180@qq.com>

On 3/3/15 21:45, Michal Hocko wrote:
> On Tue 03-03-15 06:42:01, Chen Gang wrote:
>> When !MMU, it will report warning. The related warning with allmodconfig
>> under c6x:
> 
> Does it even make any sense to enable CONFIG_MEMCG when !CONFIG_MMU?
> Is anybody using this configuration and is it actually usable? My
> knowledge about CONFIG_MMU is close to zero so I might be missing
> something but I do not see a point into fixing compile warnings when
> the whole subsystem is not usable in the first place.
> 

For me, only according to the current code, the original author assumes
CONFIG_MEMCG can still have effect when !CONFIG_MMU: "or, he/she needn't
use CONFIG_MMU switch macro in memcontrol.c".

Welcome any other members' ideas, too.

Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

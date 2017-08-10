Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1B26B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:19:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so49217wrc.12
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:19:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si4791654wrd.166.2017.08.10.01.19.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 01:19:23 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:19:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg Can't context between v1 and v2 because css->refcnt not
 released
Message-ID: <20170810081920.GG23863@dhcp22.suse.cz>
References: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
 <20170810071059.GC23863@dhcp22.suse.cz>
 <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wang Yu <yuwang668899@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

[Please do not top-post]

On Thu 10-08-17 16:10:45, wang Yu wrote:
> at first ,thanks for your reply.
> but i also tested what you said, the problem is also.
> force_empty only call try_to_free_pages, not all the pages remove
> because mem_cgroup_reparent_charges moved

Right. An alternative would be dropping the page cache globaly via
/proc/sys/vm/drop_caches. Not an ideal solution but it should help.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

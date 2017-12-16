Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFCA6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 06:52:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y23so6500650wra.16
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 03:52:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si6103601wre.338.2017.12.16.03.52.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 03:52:28 -0800 (PST)
Date: Sat, 16 Dec 2017 12:52:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20171216115227.GI16951@dhcp22.suse.cz>
References: <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
 <20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
 <20171130065335.zno7peunnl2zpozq@dhcp22.suse.cz>
 <20171130131706.0550cd28ce47aaa976f7db2a@linux-foundation.org>
 <20171201072414.3kc3pbvdbqbxhnfx@dhcp22.suse.cz>
 <20171201111845.iyoua7hhjodpuvoy@dhcp22.suse.cz>
 <20171214140608.GQ16951@dhcp22.suse.cz>
 <20171214123309.bdee142c82809f4c4ff3ce5b@linux-foundation.org>
 <20171215093618.GV16951@dhcp22.suse.cz>
 <20171215125735.1d74c7a04c05d91f27ffdbd7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171215125735.1d74c7a04c05d91f27ffdbd7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Fri 15-12-17 12:57:35, Andrew Morton wrote:
> On Fri, 15 Dec 2017 10:36:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > > 
> > > > So do we care and I will resend the patch in that case or I just drop
> > > > this from my patch queue?
> > > 
> > > Well..  I still think that silently accepting bad input would be bad
> > > practice.  If we can just delete the assertion and have such a caller
> > > reliably blow up later on then that's good enough.
> > 
> > The point is that if the caller checks for the failed allocation then
> > the result is a memory leak.
> 
> That's if page_address(highmem page) returns NULL.  I'm not sure what
> it returns, really - so many different implementations across so many
> different architectures.

I am not sure I follow. We only do care for HIGHMEM, right? And that one
returns NULL unless the high mem page is not kmaped.

> Oh well, it would have been nice to remove that VM_BUG_ON().  Why not
> just leave the code as it is now?  

BUGing on a bogus usage is not popular anymore. Also checking for
something nobody actually does is a bit pointless. I will not insist
though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

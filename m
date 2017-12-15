Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8F06B0069
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 15:57:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n126so4403533wma.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:57:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o70si5343795wmi.78.2017.12.15.12.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 12:57:38 -0800 (PST)
Date: Fri, 15 Dec 2017 12:57:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-Id: <20171215125735.1d74c7a04c05d91f27ffdbd7@linux-foundation.org>
In-Reply-To: <20171215093618.GV16951@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
	<20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
	<20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
	<20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
	<20171130065335.zno7peunnl2zpozq@dhcp22.suse.cz>
	<20171130131706.0550cd28ce47aaa976f7db2a@linux-foundation.org>
	<20171201072414.3kc3pbvdbqbxhnfx@dhcp22.suse.cz>
	<20171201111845.iyoua7hhjodpuvoy@dhcp22.suse.cz>
	<20171214140608.GQ16951@dhcp22.suse.cz>
	<20171214123309.bdee142c82809f4c4ff3ce5b@linux-foundation.org>
	<20171215093618.GV16951@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Fri, 15 Dec 2017 10:36:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > > 
> > > So do we care and I will resend the patch in that case or I just drop
> > > this from my patch queue?
> > 
> > Well..  I still think that silently accepting bad input would be bad
> > practice.  If we can just delete the assertion and have such a caller
> > reliably blow up later on then that's good enough.
> 
> The point is that if the caller checks for the failed allocation then
> the result is a memory leak.

That's if page_address(highmem page) returns NULL.  I'm not sure what
it returns, really - so many different implementations across so many
different architectures.

Oh well, it would have been nice to remove that VM_BUG_ON().  Why not
just leave the code as it is now?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

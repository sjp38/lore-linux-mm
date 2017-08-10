Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 277D26B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:06:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m80so2971416wmd.4
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:06:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si4780832wmi.231.2017.08.10.06.06.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 06:06:49 -0700 (PDT)
Date: Thu, 10 Aug 2017 15:06:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170810130645.GT23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <134bbcf4-5717-7f53-0bf1-57158e948bbe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <134bbcf4-5717-7f53-0bf1-57158e948bbe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: riel@redhat.com, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

On Mon 07-08-17 16:19:18, Florian Weimer wrote:
> On 08/07/2017 03:46 PM, Michal Hocko wrote:
> > How do they know that they need to regenerate if they do not get SEGV?
> > Are they going to assume that a read of zeros is a "must init again"? Isn't
> > that too fragile?
> 
> Why would it be fragile?  Some level of synchronization is needed to set
> things up, of course, but I think it's possible to write a lock-free
> algorithm to maintain the state even without strong guarantees of memory
> ordering from fork.

Yeah, that is what I meant as fragile... I am not question this is
impossible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

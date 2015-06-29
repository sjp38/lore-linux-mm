Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA096B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:55:08 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so76421495wib.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:55:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7si13795894wiy.79.2015.06.29.08.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 08:55:06 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:55:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
Message-ID: <20150629155504.GE4612@dhcp22.suse.cz>
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com>
 <20150629150311.GC4612@dhcp22.suse.cz>
 <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com>
 <20150629153623.GC4617@dhcp22.suse.cz>
 <559167D8.80803@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <559167D8.80803@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-06-15 11:44:24, nick wrote:
[...]
> Here is a patch series I have been trying to merge for a bug in the
> gma500 other the last few patches. There are other patches I have like
> this lying around.

I am not interested in looking at random and unrelated patches. I am
also not thrilled about random cleanups which do not have an additional
value. I will not repeat that again and will start ignoring patches like
that. I have tried to help you but this seems pointless investment of my
time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

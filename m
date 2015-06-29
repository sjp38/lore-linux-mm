Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8A56B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:36:27 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so75934716wic.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:36:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce7si74199512wjc.102.2015.06.29.08.36.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 08:36:25 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:36:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
Message-ID: <20150629153623.GC4617@dhcp22.suse.cz>
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com>
 <20150629150311.GC4612@dhcp22.suse.cz>
 <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-06-15 11:23:08, Nicholas Krause wrote:
[...]
> I agree with and looked into the callers about this wasn't sure if you
> you wanted me to return - ENOMEM.  I will rewrite this patch the other
> way. 

I am not sure this path really needs a cleanup.

> Furthermore I apologize about this and do have actual useful
> patches but will my rep it's hard to get replies from maintainers.

You can hardly expect somebody will be thrilled about your patches when
their fault rate is close to 100%. Reviewing each patch takes time and
that is a scarce resource. If you want people to follow your patches
make sure you are offering something that might be interesting or
useful. Cleanups like these usually are not interesting without
either building something bigger on top of them or when they improve
readability considerably.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

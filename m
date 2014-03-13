Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 715F96B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:04:26 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so1133802wgh.29
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 10:04:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs1si6812398wib.20.2014.03.13.10.04.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 10:04:25 -0700 (PDT)
Date: Thu, 13 Mar 2014 18:04:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2014-03-12-16-04 uploaded
Message-ID: <20140313170423.GI4473@dhcp22.suse.cz>
References: <20140312230510.69CD831C078@corp2gmr1-1.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140312230510.69CD831C078@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Wed 12-03-14 16:05:10, Andrew Morton wrote:
[...]
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series

I am sorry but I didn't get to update the last two releases and probably
wont't make the next in this release cycle because I am quite busy with
other stuff and there are too many cross tree conflicts to have this
automated (notably slab and cgroup trees are conflicting a lot). Let's
see whether I can sort it out before traveling to LSF next week
otherwise I will start after getting back (around 12th Apr. after
vacation) with a new release cycle. Sorry about that!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

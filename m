Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9CB2E6B024F
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:41:28 -0400 (EDT)
Date: Fri, 14 Sep 2012 20:41:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v3] memcg: clean up networking headers file inclusion
Message-ID: <20120914124124.GC21038@localhost>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
 <20120914120849.GL28039@dhcp22.suse.cz>
 <5052E766.9070304@parallels.com>
 <20120914122413.GO28039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120914122413.GO28039@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

> > Seems safe now. Since the config matrix can get tricky, and we have no
> > pressing time issues with this, I would advise to give it a day in
> > Fengguang's magic system before merging it. Just put it in a temp branch
> > in korg and let it do the job.
> 
> OK done. It is cleanups/memcg-sock-include.
> 
> Fengguang, do you think we can (ab)use your build test coverity to test
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git cleanups/memcg-sock-include
> 
> Thanks a lot!

Feel free to take advantage of it to your heart's content!  Actually
one of my biggest joy of working (hard) is to see users being able to
make utmost use of the resulted system or feature :)

The tests will auto start shortly after you push the branch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

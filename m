Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 145436B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 08:12:51 -0400 (EDT)
Received: by wgin8 with SMTP id n8so73276541wgi.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 05:12:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si1800338wix.88.2015.05.14.05.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 05:12:49 -0700 (PDT)
Date: Thu, 14 May 2015 14:12:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514121248.GG6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
 <20150514115641.GE6799@dhcp22.suse.cz>
 <20150514120142.GG5066@rei.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514120142.GG5066@rei.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 14-05-15 14:01:42, Cyril Hrubis wrote:
> Hi!
> > > The previous testcases does exactly this but moves the process to the
> > > parent with:
> > > 
> > > echo $pid > ../tasks
> > > 
> > > Before it tries the force_empty and expects it to succeed.
> > > 
> > > Was this some old implementation limitation that has been lifted
> > > meanwhile?
> > 
> > OK, now I remember... f61c42a7d911 ("memcg: remove tasks/children test
> > from mem_cgroup_force_empty()") which goes back to 3.16. So the test
> > case is invalid.
> 
> Then please send a patch to remove the test.

I think we can still fix both tescases and expect not to fail with
regular mmap but fail it with unreclaimable memory (e.g. disallow
swapout or use mlock).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

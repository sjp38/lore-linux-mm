Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1234F6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 08:10:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p17so6028437wmd.0
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:10:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k126si3197wmd.213.2017.08.31.05.09.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 05:09:59 -0700 (PDT)
Date: Thu, 31 Aug 2017 14:09:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170831120951.hqlu2ai5i7hly7nk@dhcp22.suse.cz>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
 <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
 <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
 <20170831111006.i7srs56xki4bjx34@shodan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170831111006.i7srs56xki4bjx34@shodan.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Savkov <asavkov@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu 31-08-17 13:10:06, Artem Savkov wrote:
> Hi Michal,
> 
> On Wed, Aug 30, 2017 at 05:43:15PM +0200, Michal Hocko wrote:
> > The previous patch is insufficient. drain_all_stock can still race with
> > the memory offline callback and the underlying memcg disappear. So we
> > need to be more careful and pin the css on the memcg. This patch
> > instead...
> 
> Tried this on top of rc7 and it does fix the splat for me.

Thanks for testing! Can I assume your Tested-by?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

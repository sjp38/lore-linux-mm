Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAB826B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 08:19:41 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e2so1329690qta.8
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:19:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r76si2878376qkh.369.2017.08.31.05.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 05:19:40 -0700 (PDT)
Date: Thu, 31 Aug 2017 14:19:37 +0200
From: Artem Savkov <asavkov@redhat.com>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170831121908.kin3mm25ebszhpvn@shodan.usersys.redhat.com>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
 <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
 <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
 <20170831111006.i7srs56xki4bjx34@shodan.usersys.redhat.com>
 <20170831120951.hqlu2ai5i7hly7nk@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170831120951.hqlu2ai5i7hly7nk@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu, Aug 31, 2017 at 02:09:51PM +0200, Michal Hocko wrote:
> On Thu 31-08-17 13:10:06, Artem Savkov wrote:
> > Hi Michal,
> > 
> > On Wed, Aug 30, 2017 at 05:43:15PM +0200, Michal Hocko wrote:
> > > The previous patch is insufficient. drain_all_stock can still race with
> > > the memory offline callback and the underlying memcg disappear. So we
> > > need to be more careful and pin the css on the memcg. This patch
> > > instead...
> > 
> > Tried this on top of rc7 and it does fix the splat for me.
> 
> Thanks for testing! Can I assume your Tested-by?

Didn't test much more than the case that was causing it, but yes.

Reported-and-tested-by: Artem Savkov <asavkov@redhat.com>

-- 
Regards,
  Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

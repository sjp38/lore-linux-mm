Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1EC326B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 16:17:34 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1187405pbb.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2012 13:17:33 -0700 (PDT)
Date: Wed, 10 Oct 2012 13:17:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-linus] memcg, kmem: fix build error when CONFIG_INET
 is disabled
In-Reply-To: <20121010143331.GA7880@localhost>
Message-ID: <alpine.DEB.2.00.1210101312330.28583@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210092325500.9528@chino.kir.corp.google.com> <5075383A.1000001@parallels.com> <20121010092700.GD23011@dhcp22.suse.cz> <50753FFF.6060102@parallels.com> <20121010143331.GA7880@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 10 Oct 2012, Fengguang Wu wrote:

> > Fengguang, was that this error? Why hasn't it showed up before in the
> > test system?
> 
> I do find this error in the build error log:
> 
>         (.text+0x867f): undefined reference to `sock_update_memcg'
>         2012-09-24 04:54:53 snb next:akpm:69921c3 x86_64-randconfig-s005 0a7f618
> 
> Unfortunately it was not reported because the build system could
> miss/ignore build bugs due to various reasons/imperfections. It has
> since then undergo lots of enhancements and as a result, the daily
> reported errors have more than doubled. :-)
> 

Not sure where this discussion is going.  Do people who can't build their 
kernel and have a fix for it need to verify that your build system shows 
the same thing first?  This isn't a false positive.

As I said in the first message, Randy reported this on September 24 (the 
same date you're reporting above) and received no response when he 
reported it to LKML here: 
http://marc.info/?l=linux-kernel&m=134852557320089

Regardless, Linus' tree is messed up and I don't think we need to go back 
reverting patches out of his tree when it's trivial to fix with my patch, 
which Michal acked.  Sheesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

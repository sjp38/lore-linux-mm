Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 76FF36B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:05:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8290621pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 13:05:46 -0700 (PDT)
Date: Fri, 20 Jul 2012 13:05:42 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
Message-ID: <20120720200542.GD21218@google.com>
References: <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120719165046.GO24336@google.com>
 <1342799140.2583.6.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342799140.2583.6.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, glommer@parallels.com

Hey, Peter.

On Fri, Jul 20, 2012 at 05:45:40PM +0200, Peter Zijlstra wrote:
> > So, Peter, why does cpuset mangle with cgroup_mutex?  What guarantees
> > does it need?  Why can't it work on "changed" notification while
> > caching the current css like blkcg does?
> 
> I've no clue sorry.. /me goes stare at this stuff.. Looks like something
> Paul Menage did when he created cgroups. I'll have to have a hard look
> at all that to untangle this. Not something obvious to me.

Yeah, it would be great if this can be untangled.  I really don't see
any other reasonable way out of this circular locking mess.  If cpuset
needs stable css association across certain period, the RTTD is
caching the css by holding its ref and synchronize modifications to
that cache, rather than synchronizing cgroup operations themselves.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

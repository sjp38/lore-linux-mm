Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id BA0706B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 05:10:46 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so2482694wgh.35
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 02:10:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pg7si16293633wjb.56.2014.06.06.02.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 02:10:44 -0700 (PDT)
Date: Fri, 6 Jun 2014 11:10:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
Message-ID: <20140606091042.GB26253@dhcp22.suse.cz>
References: <1401976841-3899-1-git-send-email-richard@nod.at>
 <1401976841-3899-2-git-send-email-richard@nod.at>
 <20140605150025.GB15939@dhcp22.suse.cz>
 <alpine.DEB.2.02.1406051358210.18119@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406051358210.18119@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Richard Weinberger <richard@nod.at>, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 05-06-14 14:01:02, David Rientjes wrote:
> On Thu, 5 Jun 2014, Michal Hocko wrote:
> 
> > If we are printing too much then OK, let's remove those parts which are
> > not that useful but hiding information which tells us more about the oom
> > decision doesn't sound right to me.
> > 
> 
> Memcg oom killer printing is controlled mostly by 
> mem_cgroup_print_oom_info(), I don't see anything in the generic oom 
> killer that should be removed and that I have not used even for memcg ooms 
> in the past.

Yes, I find most of the information printed during OOM very helpful.
After 58cf188ed649 (memcg, oom: provide more precise dump info while
memcg oom happening) even memcg oom info is helpful.

> Perhaps there could be a case made for suppressing some of the 
> hierarchical stats from being printed for memcg ooms and controlled by 
> another memcg knob, but it doesn't sound vital.

Agreed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

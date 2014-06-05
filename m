Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4206B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 17:01:07 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id hn18so8065034igb.12
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:01:06 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id hd4si14525113icb.64.2014.06.05.14.01.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 14:01:06 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id y20so1392475ier.6
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:01:05 -0700 (PDT)
Date: Thu, 5 Jun 2014 14:01:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
In-Reply-To: <20140605150025.GB15939@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1406051358210.18119@chino.kir.corp.google.com>
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at> <20140605150025.GB15939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Richard Weinberger <richard@nod.at>, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 5 Jun 2014, Michal Hocko wrote:

> If we are printing too much then OK, let's remove those parts which are
> not that useful but hiding information which tells us more about the oom
> decision doesn't sound right to me.
> 

Memcg oom killer printing is controlled mostly by 
mem_cgroup_print_oom_info(), I don't see anything in the generic oom 
killer that should be removed and that I have not used even for memcg ooms 
in the past.

Perhaps there could be a case made for suppressing some of the 
hierarchical stats from being printed for memcg ooms and controlled by 
another memcg knob, but it doesn't sound vital.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

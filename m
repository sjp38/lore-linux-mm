Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4417D6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:00:49 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so3665552wiw.14
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:00:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10si11741225wjf.73.2014.06.05.08.00.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 08:00:38 -0700 (PDT)
Date: Thu, 5 Jun 2014 17:00:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
Message-ID: <20140605150025.GB15939@dhcp22.suse.cz>
References: <1401976841-3899-1-git-send-email-richard@nod.at>
 <1401976841-3899-2-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401976841-3899-2-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 05-06-14 16:00:41, Richard Weinberger wrote:
> Don't spam the kernel logs if the oom_control event fd has listeners.
> In this case there is no need to print that much lines as user space
> will anyway notice that the memory cgroup has reached its limit.

But how do you debug why it is reaching the limit and why a particular
process has been killed?

If we are printing too much then OK, let's remove those parts which are
not that useful but hiding information which tells us more about the oom
decision doesn't sound right to me.

> Signed-off-by: Richard Weinberger <richard@nod.at>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

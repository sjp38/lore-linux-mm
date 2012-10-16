Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F201F6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:03:05 -0400 (EDT)
Date: Tue, 16 Oct 2012 09:03:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
Message-ID: <20121016070302.GA13991@dhcp22.suse.cz>
References: <1350367837-27919-1-git-send-email-handai.szj@taobao.com>
 <alpine.DEB.2.00.1210152311460.9480@chino.kir.corp.google.com>
 <507CFF65.7050109@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <507CFF65.7050109@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Sha Zhengju <handai.szj@taobao.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 16-10-12 14:32:05, Sha Zhengju wrote:
[...]
> Thanks for reminding!  Yes, I cooked it on memcg-devel git repo but
> a out-of-date
> since-3.2 branch... But I notice the latest branch is since-3.5(not
> seeing 3.6/3.7), does
> it okay to working on this branch?

The tree has moved to
http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary.
Please use that tree.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id EA58E6B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 09:38:11 -0400 (EDT)
Date: Mon, 13 May 2013 15:38:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 3/3] memcg: simplify lock of memcg page stat account
Message-ID: <20130513133809.GC5246@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <1368421545-4974-1-git-send-email-handai.szj@taobao.com>
 <20130513131251.GB5246@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130513131251.GB5246@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Mon 13-05-13 15:12:51, Michal Hocko wrote:
[...]
> I am sorry but I do not think this is the right approach. IMO we should
> focus on mem_cgroup_begin_update_page_stat and make it really recursive
> safe - ideally without any additional overhead (which sounds like a real
> challenge)

Or maybe we should just not over complicate this and simply consider
recursivness when it starts being an issue. It is not a problem for
rmap accounting anymore and dirty pages accounting seems to be safe as
well and pages under writeback accounting was OK even previously.
It doesn't make much sense to block dirty pages accounting by a
non-existing problem.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A58B56B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 10:05:51 -0400 (EDT)
Message-ID: <51642061.1090305@parallels.com>
Date: Tue, 9 Apr 2013 18:06:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: defer page_cgroup initialization
References: <1365499511-10923-1-git-send-email-glommer@parallels.com> <20130409133630.GR1953@cmpxchg.org>
In-Reply-To: <20130409133630.GR1953@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 04/09/2013 05:36 PM, Johannes Weiner wrote:
> Could you please make it either int (*)(void) OR return true for
> success? :-)
I can actually do better: I can return an error code and then do the
cleanup on error that I forgot to backport from the bypass patchset...

Thanks for drawing my attention to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

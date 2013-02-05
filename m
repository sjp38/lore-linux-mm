Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 78C706B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:12:49 -0500 (EST)
Message-ID: <51111377.4030502@parallels.com>
Date: Tue, 5 Feb 2013 18:13:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Few things I would like to discuss
References: <20130205123515.GA26229@dhcp22.suse.cz>
In-Reply-To: <20130205123515.GA26229@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 02/05/2013 04:35 PM, Michal Hocko wrote:
> Hi,
> I would like to discuss the following topics:
> * memcg oom should be more sensitive to locked contexts because now
>   it is possible that a task is sitting in mem_cgroup_handle_oom holding
>   some other lock (e.g. i_mutex or mmap_sem) up the chain which might
>   block other task to terminate on OOM so we basically end up in a
>   deadlock. Almost all memcg charges happen from the page fault path
>   where we can retry but one class of them happen from
>   add_to_page_cache_locked and that is a bit more problematic.

This is not the case with kmemcg on. Those charges will usually happen
from the slab/slub grow_cache mechanism, or during fork. This is not to
invalidate your reasoning - since those are usually tricky in terms of
context as well, and would benefit just as much - but to complete it.

> * I would really like to finally settle down on something wrt. soft
>   limit reclaim. I am pretty sure Ying would like to discuss this topic
>   as well so I will not go into details about it. I will post what I
>   have before the conference so that we can discuss her approach and
>   what was the primary disagreement the last time. I can go into more
>   ditails as a follow up if people are interested of course.

This interests me very much as well.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

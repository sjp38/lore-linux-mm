Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D98AB6B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 13:19:41 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p9HHJcrf015432
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:19:38 -0700
Received: from ggnq2 (ggnq2.prod.google.com [10.218.98.130])
	by hpaq13.eem.corp.google.com with ESMTP id p9HHF1sl013408
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:19:38 -0700
Received: by ggnq2 with SMTP id q2so5545478ggn.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:19:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E9BEDA9.6000908@parallels.com>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
	<1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
	<1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org>
	<1318639110-27714-4-git-send-email-ssouhlal@FreeBSD.org>
	<1318639110-27714-5-git-send-email-ssouhlal@FreeBSD.org>
	<4E9BEDA9.6000908@parallels.com>
Date: Mon, 17 Oct 2011 10:19:35 -0700
Message-ID: <CABCjUKAYmzZPn8N1bcinQCR63SD2P7rDL9xWo81fBf-PZ4BJNQ@mail.gmail.com>
Subject: Re: [RFC] [PATCH 4/4] memcg: Document kernel memory accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, linux-mm@kvack.org

Hello Glauber,

On Mon, Oct 17, 2011 at 1:56 AM, Glauber Costa <glommer@parallels.com> wrote:
> On 10/15/2011 04:38 AM, Suleiman Souhlal wrote:
> 3) Easier to do per-cache tuning if we ever want to.

What kind of tuning are you thinking about?

> About, on-demand creation, I think it is a nice idea. But it may impact
> allocation latency on caches that we are sure to be used, like the dentry
> cache. So that gives us:

I don't think this is really a problem, as only the first allocation
of that type is impacted.
But if it turns out it is, we can just always create them
asynchronously (which we already do if we have GFP_NOWAIT).

>> +When a kmem_cache gets migrated to the root cgroup, "dead" is appended to
>> +its name, to indicated that it is not going to be used for new
>> allocations.
>
> Why not just remove it?

Because there are still objects allocated from it.

> * We still need the ability to restrict kernel memory usage separately from
> user memory, dependent on a selectable, as we already discussed here.

This should not be difficult to add.
My main concern is when and what to reclaim, when there is a kernel
memory limit.

Thanks for the comments,
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

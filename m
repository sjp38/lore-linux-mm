Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0D59C6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 10:08:11 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id i18so684562bkv.32
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 07:08:10 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 6 Feb 2013 23:08:09 +0800
Message-ID: <CAFj3OHW=-WJegSvDG+Drb5p5kKX2s+F-irx07DxZEqH5_4Cxng@mail.gmail.com>
Subject: [LSF/MM TOPIC] [ATTEND] memcg page stat accounting and drop_caches
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>

Hi,

Recently I've been working on memcg related issues based on our
production environment and requirements, and as the 2013 LSF/MM is
coming, I'd like to discuss the following topics:

- memcg page stat stuffs
This is basically from my recent works of memcg dirty/writeback page
stat accounting(https://lkml.org/lkml/2012/12/25/95). But before them
to be ready, we'd better do some optimization toward the overhead of
accounting(my idea now is mainly on root memcg, and the first attempt
is posted in the 6/8 of the aboving patchset). Another related prepare
issue is memcg page stat lock, which is found to be too large and has
nesting problem. I'm also trying to simply it and has sent out the
proposal( http://www.spinics.net/lists/linux-mm/msg50037.html), but
now it seems that there is still other race problems. Maybe I can seek
some suggestions here.

- memcg drop_caches
There are some needs of drop_caches using in memcg or in containers
like lxc, but such interface is not available now. Another control
file 'force_empty' has some function of "drop caches and anon pages",
but it's provided to make cgroup's memory usage empty and can be used
only when the cgroup has no tasks, so it make sense to implement it.
But as to the implementation, drop_caches needs to handle both page
caches and dentry/inode caches. After a rough investigation, I think
memcg slab/slub shrinker is in the preparation stage after Glauber's
kmem infrastructure (I'm also interested and expecting his following
work about memcg shrinker mentioned in his LSF/MM proposals. : ) ) ,
and for page caches we may do some generalisation to the existing
'force_empty' interface.



Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

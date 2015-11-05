Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8075782F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:11:06 -0500 (EST)
Received: by lfs39 with SMTP id 39so29897748lfs.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:11:05 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jm1si4764647lbc.135.2015.11.05.08.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:11:05 -0800 (PST)
Date: Thu, 5 Nov 2015 19:10:48 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V2 0/2] SLUB bulk API interactions with kmem cgroup
Message-ID: <20151105161048.GG29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105153704.1115.10475.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Thu, Nov 05, 2015 at 04:37:39PM +0100, Jesper Dangaard Brouer wrote:
> I fixed some bugs for kmem cgroup interaction with SLUB bulk API,
> compiled kernel with CONFIG_MEMCG_KMEM=y, but I don't known how to
> setup kmem cgroups for slab, thus this is mostly untested.
> 
> I will appriciate anyone who can give me a simple setup script...

# create a memcg
mkdir /sys/fs/cgroup/memory/test

# enable kmem acct *before* putting any tasks in it
echo -1 > /sys/fs/cgroup/memory/test/memory.kmem.limit_in_bytes

# put a task in the cgroup
echo $$ > /sys/fs/cgroup/memory/test/cgroup.procs

# do what you want to do here

# you can check if kmem actt really works by looking at
cat /sys/fs/cgroup/memory/test/memory.kmem.slabinfo
# it should not be empty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 28B786B00FC
	for <linux-mm@kvack.org>; Sat, 22 Feb 2014 04:28:14 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id hr17so1493631lab.1
        for <linux-mm@kvack.org>; Sat, 22 Feb 2014 01:28:13 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jn5si13927612lbc.21.2014.02.22.01.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Feb 2014 01:28:12 -0800 (PST)
Message-ID: <53086DA6.4090806@parallels.com>
Date: Sat, 22 Feb 2014 13:28:06 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v3 2/7] memcg, slab: cleanup memcg cache creation
References: <cover.1392879001.git.vdavydov@parallels.com>	<210fa2501be4cbb7f7caf6ca893301f124c92a67.1392879001.git.vdavydov@parallels.com> <20140221161114.3025c658da0429b7ae9d4985@linux-foundation.org>
In-Reply-To: <20140221161114.3025c658da0429b7ae9d4985@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Tejun Heo <tj@kernel.org>

On 02/22/2014 04:11 AM, Andrew Morton wrote:
> On Thu, 20 Feb 2014 11:22:04 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> This patch cleanups the memcg cache creation path as follows:
>>  - Move memcg cache name creation to a separate function to be called
>>    from kmem_cache_create_memcg(). This allows us to get rid of the
>>    mutex protecting the temporary buffer used for the name formatting,
>>    because the whole cache creation path is protected by the slab_mutex.
>>  - Get rid of memcg_create_kmem_cache(). This function serves as a proxy
>>    to kmem_cache_create_memcg(). After separating the cache name
>>    creation path, it would be reduced to a function call, so let's
>>    inline it.
> This patch makes a huge mess when it hits linux-next's e61734c5
> ("cgroup: remove cgroup->name").  In the vicinity of
> memcg_create_kmem_cache().  That isn't the first mess e61734c5 made :(
>
> I think I got it all fixed up - please check the end result in
> http://ozlabs.org/~akpm/stuff/.

It looks good to me, thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

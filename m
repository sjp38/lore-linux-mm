Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 11FF96B0036
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 03:58:08 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id y1so3415961lam.37
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 00:58:08 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si2802632lab.40.2014.03.28.00.58.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Mar 2014 00:58:07 -0700 (PDT)
Message-ID: <53352B8D.3040402@parallels.com>
Date: Fri, 28 Mar 2014 11:58:05 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
References: <cover.1395846845.git.vdavydov@parallels.com> <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com> <xr93fvm42rew.fsf@gthelen.mtv.corp.google.com> <5333D527.2060208@parallels.com> <20140327204320.GC28590@dhcp22.suse.cz>
In-Reply-To: <20140327204320.GC28590@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On 03/28/2014 12:43 AM, Michal Hocko wrote:
> On Thu 27-03-14 11:37:11, Vladimir Davydov wrote:
> [...]
>> In fact, do we actually need to charge every random kmem allocation? I
>> guess not. For instance, filesystems often allocate data shared among
>> all the FS users. It's wrong to charge such allocations to a particular
>> memcg, IMO. That said the next step is going to be adding a per kmem
>> cache flag specifying if allocations from this cache should be charged
>> so that accounting will work only for those caches that are marked so
>> explicitly.
> 
> How do you select which caches to track?

I though we should pick some objects that are definitely used by most
processes, e.g. mm_struct, task_struct, inodes, dentries, as a first
step, and then add some new objects to the set upon requests.

Now, after Greg's explanation, I admit the idea is rather unjustified,
because charging all objects by default and providing a way to
explicitly exclude some caches from accounting requires much less
efforts and changes to the code.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

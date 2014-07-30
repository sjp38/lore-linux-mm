Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EFE746B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:46:01 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so2434469pac.31
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 16:46:01 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id se3si3875670pac.228.2014.07.30.16.45.59
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 16:46:00 -0700 (PDT)
Message-ID: <53D983B5.3020903@lge.com>
Date: Thu, 31 Jul 2014 08:45:57 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
References: <53CDF437.4090306@lge.com> <20140722073005.GT3935@laptop> <20140722093838.GA22331@quack.suse.cz> <53D8A258.7010904@lge.com> <20140730101143.GB19205@quack.suse.cz> <20140730101920.GI19379@twins.programming.kicks-ass.net>
In-Reply-To: <20140730101920.GI19379@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>



2014-07-30 i??i?? 7:19, Peter Zijlstra i?' e,?:
> On Wed, Jul 30, 2014 at 12:11:43PM +0200, Jan Kara wrote:
>>> sb_bread allocates page from movable area but it is not movable until the
>>> reference counter of the buffer-head becomes zero.
>>> There is no lock for the buffer but the reference counter acts like lock.
>>    OK, but why do you care about a single page (of at most handful if you
>> have more filesystems) which isn't movable? That shouldn't make a big
>> difference to compaction...
>
> The thing is, CMA _must_ be able to clear all the pages in its range,
> otherwise its broken.
>
> So placing nonmovable pages in a movable block utterly wrecks that.

YES. Even a single page can make CMA migration fail.

>
> Now, Ted said that there's more effectively pinned stuff from
> filesystems (and I imagine those would be things like the root inode
> etc.) and those would equally wreck this..
>
> But Gioh didn't mention any of that.. he should I suppose.

Thanks to inform me.

I thought there are more pinned stuff but I didn't know what they are.
I tried CMA migration but it failed even after I moved the sb page-cache to non-movable area.
So I just guessed there are more pinned stuff.
I am newbie and not familiar with filesystem code.

Of course all of the pinned stuff should be moved to non-movable area.

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

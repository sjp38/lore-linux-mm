Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F1392900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:00 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
References: <83ef8b69-f041-43e6-a5a9-880ff3da26f2@default>
	<20110415081054.79a164d3.akpm@linux-foundation.org>
Date: Sat, 16 Apr 2011 00:37:36 +0900
In-Reply-To: <20110415081054.79a164d3.akpm@linux-foundation.org> (Andrew
	Morton's message of "Fri, 15 Apr 2011 08:10:54 -0700")
Message-ID: <871v135xvj.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

Andrew Morton <akpm@linux-foundation.org> writes:

>> > Before I suggested a thing about cleancache_flush_page,
>> > cleancache_flush_inode.
>> > 
>> > what's the meaning of flush's semantic?
>> > I thought it means invalidation.
>> > AFAIC, how about change flush with invalidate?
>> 
>> I'm not sure the words "flush" and "invalidate" are defined
>> precisely or used consistently everywhere in computer
>> science, but I think that "invalidate" is to destroy
>> a "pointer" to some data, but not necessarily destroy the
>> data itself.   And "flush" means to actually remove
>> the data.  So one would "invalidate a mapping" but one
>> would "flush a cache".
>> 
>> Since cleancache_flush_page and cleancache_flush_inode
>> semantically remove data from cleancache, I think flush
>> is a better name than invalidate.
>> 
>> Does that make sense?
>> 
>
> nope ;)
>
> Kernel code freely uses "flush" to refer to both invalidation and to
> writeback, sometimes in confusing ways.  In this case,
> cleancache_flush_inode and cleancache_flush_page rather sound like they
> might write those things to backing store.  

I'd like to mention about *_{get,put}_page too. In linux get/put is not
meaning read/write. There is {get,put}_page those are refcount stuff
(Yeah, and I felt those methods does refcount by quick read. But it
seems to be false. There is no xen codes, so I don't know actually
though.).

And I agree, I also think the needing thing is consistency on the linux
codes (term).

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

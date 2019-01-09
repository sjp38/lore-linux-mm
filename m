Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D48D9C43444
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F22C20859
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F22C20859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40F8D8E00A1; Wed,  9 Jan 2019 11:40:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36E0D8E00A2; Wed,  9 Jan 2019 11:40:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234CC8E00A1; Wed,  9 Jan 2019 11:40:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B260E8E00A2
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so3104220eda.12
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:40:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=y4J9T9cgCv152CBgsygqKdSQJLoaWx0kHSww4JH7KwE=;
        b=iYZ9JVo7NQXrVlSCBkXyg/81R4aMzQprhof2IcQX7/7o7bj+xVzezCN7b/h/5TDZaH
         jSDu5DlQz5ab5ToqjOOSti+3sHnYmet8fXVTsZ8M0f8SCLtUon0gfmK2nYymbFZPkELC
         /fxuEMy2b7SFoQs7apUDb/PE+mck+M1CMIugmh0fRHv7tHHNAHkIOUlr92b1JZHLoF/h
         xTGQOl8h8o6eqhv0EPlekhn6yBCuuah74+hx7aruzPMZHCu3qXuMCF19X/593gSa09PZ
         ADcWv5AV/I5jB/sx19c9K9Q/BABeZFDa0gX65tawpVy9VU4UtjSDRfaPC8g48Ovw220o
         9gRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: AJcUukcjPhOZF53lKA6w/D8i5/sci7vaYh1lZOuoYvmt1iLt4eeHD8aE
	xlcNa8fBoS6BUr1Z9fGV2g+cSgaOkd63McUPPlpzL5K6eoRtgTEMzHOHHKMjYo/i3CyiZzPD05u
	PBxrrbLcLpxai7+o6VsFQ8a4T7rasL0x1Z6VGeRPdodsD1kX4pp5VZjm4Cb925BABWw==
X-Received: by 2002:a50:d94a:: with SMTP id u10mr6521660edj.214.1547052040116;
        Wed, 09 Jan 2019 08:40:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6xq/Mw0q488yRd7CmjWAN6K1LyninnIjxZ0CTsdFdmTc16DDapm+VpJXOiqkp28vNsfGjI
X-Received: by 2002:a50:d94a:: with SMTP id u10mr6521567edj.214.1547052038460;
        Wed, 09 Jan 2019 08:40:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547052038; cv=none;
        d=google.com; s=arc-20160816;
        b=WCLM64jMSaa6J6tnK/49dQvu3YGhdS4Z3lxfNOBpzgrXRYGeLAlwcaGl86u4N4C2lr
         8KPK1rei5mR0fbZZEWsdYTiL0Mo7fZhkMBwRu682wcm1oUvAIqqcoPZhz5EPmKks0YdS
         oHTx8zk3MGC7JBypdMvpGTt4l15UNek9N2xETyW7nDeyqlwPMqhrRoII3rMJIxvyer4G
         pZ02Yg1MFEKgAtvUlV8o87xkm1j6jyNavjnke73mYZAGuvXY4ckLw/EnAnw51iX3GMIR
         8JVhSteOoHi5Kxe0JpKNN3asFv1BV0ucmISPyKvF3ArOKNXpwOT6zp8hfOmLt6gLAuM8
         7tug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=y4J9T9cgCv152CBgsygqKdSQJLoaWx0kHSww4JH7KwE=;
        b=NLAKr6fARP8I+qAj6curVnC+0u6SwI8B2RV4F2Vs0S79KrLg9qn1ZAxa9UI8aGd6Ys
         1UJC8oeImJdcK0zYQ14p20KOSySTqFdJFSsfe2oe/2wyOmuiqFPNpsNjxlmuq8LcV6by
         niTfzfZQqXWMfOVEQWUBphBsYnem3HhvOGT2bJR/mBndoxuUENGxEYP5nX//AJpfohDK
         LsFGjlsBlSuI5Vs+T27QnwEgInp1z3Qk7G/h6Wef8HgpXUcJVCSTJvROJ4zG1Q1tl4e2
         ONCS7d2UusWhutG9/ktUVLlUfCyaJ2ushE3Wz3gAWcV8RRk+8gZQ7aQ7CTZU87nRS1u3
         S9Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x17-v6si1409578eji.266.2019.01.09.08.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:40:38 -0800 (PST)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E761CAFB8;
	Wed,  9 Jan 2019 16:40:37 +0000 (UTC)
From: Roman Penyaev <rpenyaev@suse.de>
To: 
Cc: Roman Penyaev <rpenyaev@suse.de>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Davidlohr Bueso <dbueso@suse.de>,
	Jason Baron <jbaron@akamai.com>,
	Joe Perches <joe@perches.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 00/15] epoll: support pollable epoll from userspace
Date: Wed,  9 Jan 2019 17:40:10 +0100
Message-Id: <20190109164025.24554-1-rpenyaev@suse.de>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190109164010.oH7rpexuJI6qNLSb9WfkSN5zvv7cHHt0cbhpkUu2Ugk@z>

Hi all,

This series introduces pollable epoll from userspace, i.e. user creates
epfd with a new EPOLL_USERPOLL flag, mmaps epoll descriptor, gets header
and ring pointers and then consumes ready events from a ring, avoiding
epoll_wait() call.  When ring is empty, user has to call epoll_wait()
in order to wait for new events.  epoll_wait() returns -ESTALE if user
ring has events in the ring (kind of indication, that user has to consume
events from the user ring first, I could not invent anything better than
returning -ESTALE).

For user header and user ring allocation I used vmalloc_user().  I found
that it is much easy to reuse remap_vmalloc_range_partial() instead of
dealing with page cache (like aio.c does).  What is also nice is that
virtual address is properly aligned on SHMLBA, thus there should not be
any d-cache aliasing problems on archs with vivt or vipt caches.

Also I required vrealloc(), which can hide all this "alloc new area - get
pages - map pages" stuff.  So vrealloc() is introduced in first 3 patches.

** Limitations
    
1. Expect always EPOLLET flag for new epoll items (Edge Triggered behavior)
     obviously we can't call vfs_epoll() from userpace to have level
     triggered behaviour.
    
2. No support for EPOLLWAKEUP
     events are consumed from userspace, thus no way to call __pm_relax()
    
3. No support for EPOLLEXCLUSIVE
     If device does not pass pollflags to wake_up() there is no way to
     call poll() from the context under spinlock, thus special work is
     scheduled to offload polling.  In this specific case we can't
     support exclusive wakeups, because we do not know actual result
     of scheduled work and have to wake up every waiter.
    
4. No support for nesting of epoll descriptors polled from userspace
     no real good reason to scan ready events of user ring from the
     kernel, so just do not do that.


** Principle of operation

* Basic structures shared with userspace:

In order to consume events from userspace all inserted items should be
stored in items array, which has original epoll_event field and u32
field for keeping ready events, i.e. each item has the following struct:

 struct user_epitem {
    unsigned int ready_events;
    struct epoll_event event;
 };
 BUILD_BUG_ON(sizeof(struct user_epitem) != 16);

And the following is a header, which is seen by userspace:

 struct user_header {
    unsigned int magic;          /* epoll user header magic */
    unsigned int state;          /* epoll ring state */
    unsigned int header_length;  /* length of the header + items */
    unsigned int index_length;   /* length of the index ring */
    unsigned int max_items_nr;   /* max num of items slots */
    unsigned int max_index_nr;   /* max num of items indeces, always pow2 */
    unsigned int head;           /* updated by userland */
    unsigned int tail;           /* updated by kernel */
    unsigned int padding[24];    /* Header size is 128 bytes */

    struct user_epitem items[];
 };

 /* Header is 128 bytes, thus items are aligned on CPU cache */
 BUILD_BUG_ON(sizeof(struct user_header) != 128);

From the very beginning kernel allocates 1 page for user header, i.e. by
default we have 248 items for 4096 size page.

When 249'th item is inserted special expanding should be done, which will
be discussed later.

Ready events are kept in a ring buffer, which is simply an index table,
where each element points to an item in a header:

 unsinged int *user_index;

Kernel allocates also 1 page for user index, i.e. for 4096 page we have
1024 ring elements capacity.


* How is new event accounted on kernel side?  Hot it is consumed from
* userspace?

When new event comes for some epoll item kernel does the following:

 struct user_epitem *uitem;

 /* Each item has a bit (index in user items array), discussed later */
 uitem = user_header->items[epi->bit];

 if (!atomic_fetch_or(uitem->ready_events, pollflags)) {
     i = atomic_add(&ep->user_header->tail, 1);

     item_idx = &user_index[i & index_mask];

     /* Signal with a bit, user spins on index expecting value > 0 */
     *item_idx = idx + 1;

    /*
     * Want index update be flushed from CPU write buffer and
     * immediately visible on userspace side to avoid long busy
     * loops.
     */
     smp_wmb();
 }

Important thing here is that ring can't infinitely grow and corrupt other
elements, because kernel always checks that item was marked as ready, so
userspace has to clear ready_events field.

On userside events the following code should be used in order to consume
events:

 tail = READ_ONCE(header->tail);
 for (i = 0; header->head != tail; header->head++) {
     item_idx_ptr = &index[idx & indeces_mask];

     /*
      * Spin here till we see valid index
      */
     while (!(idx = __atomic_load_n(item_idx_ptr, __ATOMIC_ACQUIRE)))
         ;

     item = &header->items[idx - 1];

     /*
      * Mark index as invalid, that is for userspace only, kernel does not care
      * and will refill this pointer only when observes that event is cleared,
      * which happens below.
      */
     *item_idx_ptr = 0;

     /*
      * Fetch data first, if event is cleared by the kernel we drop the data
      * returning false.
      */
     event->data = item->event.data;
     event->events = __atomic_exchange_n(&item->ready_events, 0,
                         __ATOMIC_RELEASE);

 }


* How new epoll item gets its index inside user items array?

Kernel has a bitmap for that and gets free bit on attempt to insert a new
epoll item.  When bitmap is full - it has been expanded.

* What happens when user items or user index has to be expanded or shrunk?

For that quite rare cases kernel has to ask userspace to invoke epoll_wait()
in order to reallocate all user pointers under locks, i.e. for that
particular period all events are routed to kernel lists instead of user
ring and kernel sets special INACTIVE state in user header in order to
notify user that new event's won't appear in the ring until the user
calls epoll_wait().  Worth to mention, that expand is done directly inside
ep_insert(), because expand is an allocation of a new page and recreation
of virtual area on kernel side, which does not affect mappings on userside.

* How userspace detects that kernel has expanded or shrunk the memory?

Any of the item ctl operations (add, mod, del) can be executed in parallel
with events consumption from user ring.

Expand is safe from user perspective (new pages is mapped to kernel side,
but user does not know and care about that), so expand happens directly
in epoll_ctl(EPOLL_CTL_ADD), but kernel routes all new events to kernel
lists and asks user to call epoll_wait() with special INACTIVE state.

Shrink is a bit different.  When epoll_ctl(EPOLL_CTL_DEL) is called and
kernel decides to shrink the memory, it routes new events to kernel lists,
marks user header state as INACTIVE and does not put item bit immediately,
but postpones it until user calls epoll_wait() (which should happen soon,
because user_header->state is INACTIVE and user should come to sleep to
kernel).  So shrink happens only on epoll_wait() call with all necessary
locks taken.

Bit put should be postponed because user can observe corrupted event item
if events are not yet consumed from the ring, bit is put and then
immediately reused by concurrent item insert.  To avoid this possible
race bit put is postponed when header state is INACTIVE and all events
are routed to kernel lists.

So returning to the quesion: how userspace detects that kernel has changed
the memory?  User has to cache lengths before epoll_wait(), compare old
cached values with new from header and call mremap() if values differ:

 header_length = header->header_length;
 index_length = header->index_length;

 rc = epoll_wait(epfd, NULL, 0, -1);
 assert(rc < 0);
 if (errno != -ESTALE)
     return -errno;

 if (header_length != header->header_length) {
    header = mremap(header, header_length, header->header_length, MREMAP_MAYMOVE);
    assert(header != MAP_FAILED);
 }
 if (index_length != header->index_length) {
    index = mremap(index, index_length, header->index_length, MREMAP_MAYMOVE);
    assert(index != MAP_FAILED);
 }

* Is it possible to consume events from many threads on userspace side?

That should be possible in a lockless manner, and kernel keeps extra number
of free slots in a ring (EPOLL_USER_EXTRA_INDEX_NR = 16) in order to let
user consume events from up to 16 threads in parallel.

It seems that this can be a good feature thinking about performance, but I
could not decide is it enough to report this value in a user header or let
user change that somehow on epoll_create1() call (or a new one?).

* Is there any testing app available?

There is a small app [1] which starts many threads with many event fds and
produces many events, while single consumer fetches them from userspace
and goes to kernel from time to time in order to wait.


This is RFC because for memory allocation I used vmalloc(), which virtual
space for kernel seems limited for some archs.  So for example for 1 mln
of items kernel has to allocate 10^6 x 16 [items] + 10^6 x 4 [index],
that is around ~20mb, seems very small, but not sure is it ok or not.

I temporarily used gcc atomic builtins on kernel side, because I did find
any good way to atomically update plain unsigned int of user_header
structure without casting it to atomic_t.  Or casting is fine in that case?

There are not enough good, informative and shiny comments in the code,
explaining all the machinery.  The most hard part is left, I would say.

Only very basic scenarios are tested, all these things with user
reallocations (expand, shrink) are not tested at all.

[1] https://github.com/rouming/test-tools/blob/master/userpolled-epoll.c

Roman Penyaev (15):
  mm/vmalloc: add new 'alignment' field for vm_struct structure
  mm/vmalloc: move common logic from  __vmalloc_area_node to a separate
    func
  mm/vmalloc: introduce new vrealloc() call and its subsidiary reach
    analog
  epoll: move private helpers from a header to the source
  epoll: introduce user header structure and user index for polling from
    userspace
  epoll: introduce various of helpers for user structure lengths
    calculations
  epoll: extend epitem struct with new members for polling from
    userspace
  epoll: some sanity flags checks for epoll syscalls for polled epfd
    from userspace
  epoll: introduce stand-alone helpers for polling from userspace
  epoll: support polling from userspace for ep_insert()
  epoll: offload polling to a work in case of epfd polled from userspace
  epoll: support polling from userspace for ep_remove()
  epoll: support polling from userspace for ep_modify()
  epoll: support polling from userspace for ep_poll()
  epoll: support mapping for epfd when polled from userspace

 fs/eventpoll.c                 | 1042 +++++++++++++++++++++++++++++---
 include/linux/vmalloc.h        |    4 +
 include/uapi/linux/eventpoll.h |   15 +-
 mm/vmalloc.c                   |  152 ++++-
 4 files changed, 1117 insertions(+), 96 deletions(-)

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Davidlohr Bueso <dbueso@suse.de>
Cc: Jason Baron <jbaron@akamai.com>
Cc: Joe Perches <joe@perches.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
-- 
2.19.1


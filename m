Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1486B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 07:18:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d14-v6so3982004qtn.12
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 04:18:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g187-v6si515601qkb.320.2018.08.03.04.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 04:18:49 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <8347.1533292272@warthog.procyon.org.uk>
References: <8347.1533292272@warthog.procyon.org.uk> <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com> <153320759911.18959.8842396230157677671.stgit@localhost.localdomain> <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <12713.1533295125.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 03 Aug 2018 12:18:45 +0100
Message-ID: <12714.1533295125@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: dhowells@redhat.com, Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org

David Howells <dhowells@redhat.com> wrote:

> But!  I'm not sure why the reproducer works at all because the umount2()=
 call
> is *after* the chroot, so should fail on ENOENT before it even gets that
> far.

No, it shouldn't.  It did chroot() not chdir().

> In fact, umount2() can be called multiple times, apparently successfully=
, and
> doesn't actually unmount anything.

Okay, because it chroot'd into the directory.  Should it return EBUSY thou=
gh?

David

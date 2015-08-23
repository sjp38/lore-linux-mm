Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4A89F6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 17:56:31 -0400 (EDT)
Received: by labia3 with SMTP id ia3so2291955lab.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 14:56:30 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id qo3si11533813lbb.122.2015.08.23.14.56.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 14:56:28 -0700 (PDT)
Received: by lalv9 with SMTP id v9so66616794lal.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 14:56:28 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
References: <20150823060443.GA9882@gmail.com>
	<20150823064603.14050.qmail@ns.horizon.com>
	<20150823081750.GA28349@gmail.com>
Date: Sun, 23 Aug 2015 23:56:24 +0200
In-Reply-To: <20150823081750.GA28349@gmail.com> (Ingo Molnar's message of
	"Sun, 23 Aug 2015 10:17:51 +0200")
Message-ID: <87h9npwtx3.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

I was curious why these fields were ever added to /proc/meminfo, and dug
up this:

commit d262ee3ee6ba4f5f6125571d93d9d63191d2ef76
Author: Andrew Morton <akpm@digeo.com>
Date:   Sat Apr 12 12:59:04 2003 -0700

    [PATCH] vmalloc stats in /proc/meminfo
    
    From: Matt Porter <porter@cox.net>
    
    There was a thread a while back on lkml where Dave Hansen proposed this
    simple vmalloc usage reporting patch.  The thread pretty much died out as
    most people seemed focused on what VM loading type bugs it could solve.  I
    had posted that this type of information was really valuable in debugging
    embedded Linux board ports.  A common example is where people do arch
    specific setup that limits there vmalloc space and then they find modules
    won't load.  ;) Having the Vmalloc* info readily available is real useful in
    helping folks to fix their kernel ports.

That thread is at <http://thread.gmane.org/gmane.linux.kernel/53360>.

[Maybe one could just remove the fields and see if anybody actually
notices/cares any longer. Or, if they are only used by kernel
developers, put them in their own file.]

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

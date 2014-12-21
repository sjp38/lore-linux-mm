Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8D06B0032
	for <linux-mm@kvack.org>; Sun, 21 Dec 2014 13:02:53 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so4466660pad.38
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 10:02:53 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qd7si22336176pbb.22.2014.12.21.10.02.51
        for <linux-mm@kvack.org>;
        Sun, 21 Dec 2014 10:02:52 -0800 (PST)
Message-ID: <54970B49.3070104@linux.intel.com>
Date: Sun, 21 Dec 2014 10:02:49 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com> <20141220183613.GA19229@phnom.home.cmpxchg.org> <20141220194457.GA3166@x61.redhat.com>
In-Reply-To: <20141220194457.GA3166@x61.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On 12/20/2014 11:44 AM, Rafael Aquini wrote:
>> > 
>> > It would be simpler to include this unconditionally.  Otherwise you
>> > are forcing everybody parsing the file and trying to run calculations
>> > of it to check for its presence, and then have them fall back and get
>> > the value from somewhere else if not.
> I'm fine either way, it makes the change even simpler. Also, if we
> decide to get rid of page_size != PAGE_SIZE condition I believe we can 
> also get rid of that "huge" hint being conditionally printed out too.

That would break existing users of the "huge" flag.  That makes it out
of the question, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

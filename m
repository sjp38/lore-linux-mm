Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 65FB16B0036
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 02:23:55 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so1246424pdb.10
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 23:23:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rf10si6155578pab.26.2014.09.19.23.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Sep 2014 23:23:54 -0700 (PDT)
Date: Fri, 19 Sep 2014 23:23:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned
 memory
Message-Id: <20140919232348.1a2856c1.akpm@linux-foundation.org>
In-Reply-To: <CALYGNiOwrM+LiadZGh+jeFgXCuCA0z_1Vd_kdMxLjqnP9Fnmhw@mail.gmail.com>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164120.29066.8857.stgit@zurg>
	<20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org>
	<CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
	<20140912224221.9ee5888a.akpm@linux-foundation.org>
	<CALYGNiNg5yLbAvqwG3nPqWZHkqXc1-3p4yqdP2Eo2rNJbRo0rg@mail.gmail.com>
	<20140919143520.94f4a17f752398a6c7c927d8@linux-foundation.org>
	<CALYGNiOwrM+LiadZGh+jeFgXCuCA0z_1Vd_kdMxLjqnP9Fnmhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 20 Sep 2014 09:25:01 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> >
> > So I'm going to send "fix for
> > mm-balloon_compaction-use-common-page-ballooning-v2" to Linus
> > separately, but it has no changelog at all.
> 
> Probably it would be better if you drop everything except actually
> fixes and stresstest. This is gone too far, now balloon won't compile
> in the middle of patchset. Just tell me and I'll redo the rest.

I think it's best if I drop everything:

mm-balloon_compaction-ignore-anonymous-pages.patch
mm-balloon_compaction-keep-ballooned-pages-away-from-normal-migration-path.patch
mm-balloon_compaction-isolate-balloon-pages-without-lru_lock.patch
selftests-vm-transhuge-stress-stress-test-for-memory-compaction.patch
mm-introduce-common-page-state-for-ballooned-memory.patch
mm-balloon_compaction-use-common-page-ballooning.patch
mm-balloon_compaction-general-cleanup.patch
mm-balloon_compaction-use-common-page-ballooning-v2-fix-1.patch

Please go through it and send out a new version?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

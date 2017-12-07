Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A59B6B025F
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 19:32:30 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h12so2984008wre.12
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 16:32:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b196si2746548wmf.157.2017.12.06.16.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 16:32:28 -0800 (PST)
Date: Wed, 6 Dec 2017 16:32:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Message-Id: <20171206163226.5f46132aeea6fbcc44fc8421@linux-foundation.org>
In-Reply-To: <20171206050547.GA5260@X58A-UD3R>
References: <94eb2c0d010a4e7897055f70535b@google.com>
	<20171204083339.GF8365@quack2.suse.cz>
	<80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
	<CACT4Y+arqmp6RW4mt3EyaPqxqxPyY31kjDLftnof5DkwfyoyRQ@mail.gmail.com>
	<20171206050547.GA5260@X58A-UD3R>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Peter Zijlstra <peterz@infradead.org>, kernel-team@lge.com

On Wed, 6 Dec 2017 14:05:47 +0900 Byungchul Park <byungchul.park@lge.com> wrote:

> > What is cross-release? Is it something new? Should we always enable
> > crossrelease_fullstack during testing?
> 
> Hello Dmitry,
> 
> Yes, it's new one making lockdep track wait_for_completion() as well.
> 
> And we should enable crossrelease_fullstack if you don't care system
> slowdown but testing.

We should update Documentation/process/submit-checklist.rst section 12.
But that list doesn't even mention CONFIG_LOCKDEP so a bit of
maintenance work will be needed there..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

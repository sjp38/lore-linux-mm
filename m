Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4EA66810D0
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:16:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z96so97336wrb.7
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:16:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i124si1849429wma.122.2017.08.25.14.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:16:40 -0700 (PDT)
Date: Fri, 25 Aug 2017 14:16:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-Id: <20170825141637.f11a36a9997b4b705d5b6481@linux-foundation.org>
In-Reply-To: <20170824085553.GB5943@dhcp22.suse.cz>
References: <20170808132554.141143-1-dancol@google.com>
	<20170810001557.147285-1-dancol@google.com>
	<20170810043831.GB2249@bbox>
	<20170810084617.GI23863@dhcp22.suse.cz>
	<r0251soju3fo.fsf@dancol.org>
	<20170810105852.GM23863@dhcp22.suse.cz>
	<CAPz6YkUNu1uH057ENuH+Umq5J=J24my0p91mvYMtEb4Vy6Dhqg@mail.gmail.com>
	<CAEe=SxkgPUEkHdQm+M49EBc_Y_bEnNbe5fed3yALUx2eUbMrGQ@mail.gmail.com>
	<20170824085553.GB5943@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Murray <timmurray@google.com>, Sonny Rao <sonnyrao@chromium.org>, Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Robert Foss <robert.foss@collabora.com>, linux-api@vger.kernel.org, Luigi Semenzato <semenzato@google.com>

On Thu, 24 Aug 2017 10:55:53 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > If we assume that the number of VMAs is going to increase over time,
> > then doing anything we can do to reduce the overhead of each VMA
> > during PSS collection seems like the right way to go, and that means
> > outputting an aggregate statistic (to avoid whatever overhead there is
> > per line in writing smaps and in reading each line from userspace).
> > 
> > Also, Dan sent me some numbers from his benchmark measuring PSS on
> > system_server (the big Android process) using smaps vs smaps_rollup:
> > 
> > using smaps:
> > iterations:1000 pid:1163 pss:220023808
> >  0m29.46s real 0m08.28s user 0m20.98s system
> > 
> > using smaps_rollup:
> > iterations:1000 pid:1163 pss:220702720
> >  0m04.39s real 0m00.03s user 0m04.31s system
> 
> I would assume we would do all we can to reduce this kernel->user
> overhead first before considering a new user visible file. I haven't
> seen any attempts except from the low hanging fruid I have tried.

It's hard to believe that we'll get anything like a 5x speedup via
optimization of the existing code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

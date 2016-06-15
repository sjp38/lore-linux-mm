Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0CA06B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 21:01:04 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so8612031pad.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:01:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e1si41624722pfb.36.2016.06.14.18.01.03
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 18:01:04 -0700 (PDT)
Date: Wed, 15 Jun 2016 10:01:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160615010107.GE17127@bbox>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <1465837595.2756.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465837595.2756.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangwoo Park <sangwoo2.park@lge.com>

On Mon, Jun 13, 2016 at 01:06:35PM -0400, Rik van Riel wrote:
> On Mon, 2016-06-13 at 16:50 +0900, Minchan Kim wrote:
> > These day, there are many platforms available in the embedded market
> > and sometime, they has more hints about workingset than kernel so
> > they want to involve memory management more heavily like android's
> > lowmemory killer and ashmem or user-daemon with lowmemory notifier.
> > 
> > This patch adds add new method for userspace to manage memory
> > efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
> > any process anytime.
> > 
> 
> Could it make sense to invoke this automatically,
> perhaps from the Android low memory killer code?

It's doable. In fact, It was first internal implementation of our
product. However, I wanted to use it on platforms which don't have
lowmemory killer. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

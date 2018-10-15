Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0683D6B026B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:44:48 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z9-v6so17014747iog.18
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:44:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p184-v6sor5121597iod.17.2018.10.15.11.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 11:44:47 -0700 (PDT)
Date: Mon, 15 Oct 2018 12:44:43 -0600
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] mm: detect numbers of vmstat keys/values mismatch
Message-ID: <20181015184443.GA175390@google.com>
References: <20181015183841.114341-1-yuzhao@google.com>
 <CAG48ez1AEpYx_nDCaNUbw7RdtsCBvAR8=SKSgyaoeSrhqRZ27w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1AEpYx_nDCaNUbw7RdtsCBvAR8=SKSgyaoeSrhqRZ27w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, jack@suse.cz, David Rientjes <rientjes@google.com>, kemi.wang@intel.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, guro@fb.com, Kees Cook <keescook@chromium.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, bigeasy@linutronix.de, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Oct 15, 2018 at 08:41:52PM +0200, Jann Horn wrote:
> On Mon, Oct 15, 2018 at 8:38 PM Yu Zhao <yuzhao@google.com> wrote:
> > There were mismatches between number of vmstat keys and number of
> > vmstat values. They were fixed recently by:
> >   commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
> >   commit 28e2c4bb99aa ("mm/vmstat.c: fix outdated vmstat_text")
> >
> > Add a BUILD_BUG_ON to detect such mismatch and hopefully prevent
> > it from happening again.
> 
> A BUILD_BUG_ON() like this is already in the mm tree:
> https://ozlabs.org/~akpm/mmotm/broken-out/mm-vmstat-assert-that-vmstat_text-is-in-sync-with-stat_items_size.patch

My bad! Didn't notice this. Please disregard this patch.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C3A1C900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 15:13:49 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so5824943pdb.2
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 12:13:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rp15si41655988pab.235.2014.07.07.12.13.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 12:13:48 -0700 (PDT)
Date: Mon, 7 Jul 2014 12:13:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/3] free reclaimed pages by paging out instantly
Message-Id: <20140707121346.1487c20e2a9365325e3a81a6@linux-foundation.org>
In-Reply-To: <20140703005949.GC21751@bbox>
References: <1404260029-11525-1-git-send-email-minchan@kernel.org>
	<20140702134215.2bf830dcb904c34bd2e2b9e8@linux-foundation.org>
	<20140703005949.GC21751@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, 3 Jul 2014 09:59:49 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > > Most of field in vmstat are not changed too much but things I can notice
> > > is allocstall and pgrotated. We could save allocstall(ie, direct relcaim)
> > > and pgrotated very much.
> > > 
> > > Welcome testing, review and any feedback!
> > 
> > Well, it will worsen IRQ latencies and it's all more code for us to
> > maintain.  I think I'd like to see a better story about the end-user
> > benefits before proceeding.
> 
> The motivation was from per-process reclaim(which was internal feature
> yet and and I will repost it soon).
> It's a feature for us to manage memory from platform so that we could
> avoid reclaim.
> 
> Anyway, userspace expect they could see increased free pages in vmstat
> after they have done per-process reclaim so the logic of userspace
> will control their next action depending on the number of current
> free page but it doesn't work with existing rotation logic, expecially
> anon swap write pages.
> 
> When I posted this patchset firstly, Rik was positive and I thought
> this feature is useful for everyone as well as per-process reclaim
> and don't want to make noise this patchset with perpcoess reclaim.
> 
> https://lkml.org/lkml/2013/5/12/174
> https://lkml.org/lkml/2013/5/14/484
> 
> Could you tell me what should I do to proceed?

Quantify the gains, quantify the losses then demonstrate that the
benefits of the gains exceeds the cost of the losses plus the cost of
ongoing maintenance!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

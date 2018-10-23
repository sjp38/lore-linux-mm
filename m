Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A97C6B0006
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:34:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c13-v6so349463ede.6
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 22:34:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1-v6si231497eji.299.2018.10.22.22.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 22:34:02 -0700 (PDT)
Date: Tue, 23 Oct 2018 07:33:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Message-ID: <20181023053359.GL18839@dhcp22.suse.cz>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <20181022181122.GK18839@dhcp22.suse.cz>
 <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sudhilal <getarunks@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia.lawall@lip6.fr>

[Trimmed CC list + Julia - there is indeed no need to CC everybody maintain a
file you are updating for the change like this]

On Tue 23-10-18 10:16:51, Arun Sudhilal wrote:
> On Mon, Oct 22, 2018 at 11:41 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 22-10-18 22:53:22, Arun KS wrote:
> > > Remove managed_page_count_lock spinlock and instead use atomic
> > > variables.
> >
> 
> Hello Michal,
> > I assume this has been auto-generated. If yes, it would be better to
> > mention the script so that people can review it and regenerate for
> > comparision. Such a large change is hard to review manually.
> 
> Changes were made partially with script.  For totalram_pages and
> totalhigh_pages,
> 
> find dir -type f -exec sed -i
> 's/totalram_pages/atomic_long_read(\&totalram_pages)/g' {} \;
> find dir -type f -exec sed -i
> 's/totalhigh_pages/atomic_long_read(\&totalhigh_pages)/g' {} \;
> 
> For managed_pages it was mostly manual edits after using,
> find mm/ -type f -exec sed -i
> 's/zone->managed_pages/atomic_long_read(\&zone->managed_pages)/g' {}
> \;

I guess we should be able to use coccinelle for this kind of change and
reduce the amount of manual intervention to absolute minimum.
-- 
Michal Hocko
SUSE Labs

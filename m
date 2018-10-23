Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0AC06B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 03:11:32 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id u14-v6so207413ybi.3
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 00:11:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3-v6sor162087ybm.176.2018.10.23.00.11.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 00:11:31 -0700 (PDT)
MIME-Version: 1.0
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <20181022181122.GK18839@dhcp22.suse.cz> <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com>
 <20181023053359.GL18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810230711220.2343@hadrien>
In-Reply-To: <alpine.DEB.2.21.1810230711220.2343@hadrien>
From: Arun Sudhilal <getarunks@gmail.com>
Date: Tue, 23 Oct 2018 12:41:19 +0530
Message-ID: <CABOM9Zr48HTphfbmk9v7a3A+cqzrAFZT71pEyvvseV8PpbWOhg@mail.gmail.com>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: julia.lawall@lip6.fr
Cc: mhocko@kernel.org, arunks@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, mhocko@suse.com, gregkh@linuxfoundation.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 23, 2018 at 12:11 PM Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
>
> On Tue, 23 Oct 2018, Michal Hocko wrote:
>
> > [Trimmed CC list + Julia - there is indeed no need to CC everybody maintain a
> > file you are updating for the change like this]
> >
> > On Tue 23-10-18 10:16:51, Arun Sudhilal wrote:
> > > On Mon, Oct 22, 2018 at 11:41 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Mon 22-10-18 22:53:22, Arun KS wrote:
> > > > > Remove managed_page_count_lock spinlock and instead use atomic
> > > > > variables.
> > > >
> > >
> > > Hello Michal,
> > > > I assume this has been auto-generated. If yes, it would be better to
> > > > mention the script so that people can review it and regenerate for
> > > > comparision. Such a large change is hard to review manually.
> > >
> > > Changes were made partially with script.  For totalram_pages and
> > > totalhigh_pages,
> > >
> > > find dir -type f -exec sed -i
> > > 's/totalram_pages/atomic_long_read(\&totalram_pages)/g' {} \;
> > > find dir -type f -exec sed -i
> > > 's/totalhigh_pages/atomic_long_read(\&totalhigh_pages)/g' {} \;
> > >
> > > For managed_pages it was mostly manual edits after using,
> > > find mm/ -type f -exec sed -i
> > > 's/zone->managed_pages/atomic_long_read(\&zone->managed_pages)/g' {}
> > > \;
> >
> > I guess we should be able to use coccinelle for this kind of change and
> > reduce the amount of manual intervention to absolute minimum.
>
> Coccinelle looks like it would be desirable, especially in case the word
> zone is not always used.
>
> Arun, please feel free to contact me if you want to try it and need help.

Thanks Julia. I m starting with,
http://coccinelle.lip6.fr/papers/backport_edcc15.pdf

Regards,
Arun
>
> julia
